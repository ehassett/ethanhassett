import type { MiddlewareHandler } from "astro";
import Mailgun from "mailgun.js";

// API URLs
const TURNSTILE_VERIFY_URL =
  "https://challenges.cloudflare.com/turnstile/v0/siteverify";

// Validation constants
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MAX_MESSAGE_LENGTH = 2000;

// Route and configuration
const CONTACT_ROUTE = "/contact";
const CONTACT_EMAIL = "contact@hassett.io";
const MAILGUN_USERNAME = "api";
const SUCCESS_REDIRECT_URL = "/contact?success=true";
const HTTP_STATUS = {
  SEE_OTHER: 303,
  INTERNAL_SERVER_ERROR: 500,
} as const;

// Form field names
const FORM_FIELDS = {
  NAME: "name",
  EMAIL: "email",
  MESSAGE: "message",
  TURNSTILE: "cf-turnstile-response",
} as const;

// Error messages
const ERROR_MESSAGES = {
  VALIDATION: {
    NAME_REQUIRED: "Please enter your name.",
    EMAIL_INVALID: "Please enter a valid email.",
    MESSAGE_REQUIRED: "Please enter a message.",
    MESSAGE_TOO_LONG: (max: number) =>
      `Message must be less than ${max} characters.`,
  },
  SERVER: {
    TURNSTILE_FAILED: "Turnstile verification failed",
    MAILGUN_FAILED: "Mailgun failed to send",
  },
} as const;

interface ContactField {
  value: string;
  error: string;
}

interface ContactData {
  name: ContactField;
  email: ContactField;
  message: ContactField;
  serverError: boolean;
}

interface TurnstileVerificationResult {
  success: boolean;
  [key: string]: unknown;
}

function validateContactData(contact: ContactData): boolean {
  if (typeof contact.name.value !== "string" || contact.name.value.length < 1) {
    contact.name.error = ERROR_MESSAGES.VALIDATION.NAME_REQUIRED;
  }
  if (
    typeof contact.email.value !== "string" ||
    !EMAIL_REGEX.test(contact.email.value)
  ) {
    contact.email.error = ERROR_MESSAGES.VALIDATION.EMAIL_INVALID;
  }
  if (typeof contact.message.value !== "string") {
    contact.message.error = ERROR_MESSAGES.VALIDATION.MESSAGE_REQUIRED;
  }
  if (contact.message.value.length > MAX_MESSAGE_LENGTH) {
    contact.message.error =
      ERROR_MESSAGES.VALIDATION.MESSAGE_TOO_LONG(MAX_MESSAGE_LENGTH);
  }

  return Object.values(contact).some(
    (field) => typeof field === "object" && "error" in field && field.error,
  );
}

async function verifyTurnstile(
  secret: string,
  response: string | null,
  remoteip: string | null,
): Promise<void> {
  return fetch(TURNSTILE_VERIFY_URL, {
    body: JSON.stringify({ secret, response, remoteip }),
    method: "POST",
    headers: { "Content-Type": "application/json" },
  })
    .then((res) => res.json() as Promise<TurnstileVerificationResult>)
    .then((result) => {
      console.log("Turnstile verification:", result);
      if (!result.success) {
        throw new Error(ERROR_MESSAGES.SERVER.TURNSTILE_FAILED);
      }
    });
}

async function sendEmail(
  apiKey: string,
  domain: string,
  contact: ContactData,
): Promise<void> {
  const mailgun = new Mailgun(FormData);
  const mg = mailgun.client({
    username: MAILGUN_USERNAME,
    key: apiKey,
    useFetch: true,
  });

  await mg.messages
    .create(domain, {
      from: `postmaster@${domain}`,
      to: [CONTACT_EMAIL],
      subject: `Contact Form Submission: ${contact.name.value}`,
      text: `Name: ${contact.name.value}\nEmail: ${contact.email.value}\nMessage: ${contact.message.value}`,
    })
    .then((msg) => console.log(msg));
}

export const onRequest: MiddlewareHandler = async (context, next) => {
  const { request, locals, redirect } = context;
  const url = new URL(request.url);

  // Only handle POST requests to /contact
  if (request.method === "POST" && url.pathname === CONTACT_ROUTE) {
    const { env } = locals.runtime;
    const contact: ContactData = {
      name: { value: "", error: "" },
      email: { value: "", error: "" },
      message: { value: "", error: "" },
      serverError: false,
    };

    try {
      // Get the form data
      const formData = await request.formData();
      contact.name.value = formData.get(FORM_FIELDS.NAME) as string;
      contact.email.value = formData.get(FORM_FIELDS.EMAIL) as string;
      contact.message.value = formData.get(FORM_FIELDS.MESSAGE) as string;

      // Validate the data
      const hasErrors = validateContactData(contact);
      if (hasErrors) {
        locals.contact = contact;
        return next();
      }

      // Verify Turnstile
      await verifyTurnstile(
        env.TURNSTILE_SECRET_KEY,
        formData.get(FORM_FIELDS.TURNSTILE) as string,
        request.headers.get("CF-Connecting-IP"),
      );

      // Send the email
      await sendEmail(env.MAILGUN_API_KEY, env.MAILGUN_DOMAIN, contact);

      // Redirect to success page
      return redirect(SUCCESS_REDIRECT_URL, HTTP_STATUS.SEE_OTHER);
    } catch (error) {
      console.error(error);

      // Preserve form data and add server error flag
      contact.serverError = true;
      locals.contact = contact;

      // Return response with 500 status and render the page
      const response = await next();
      return new Response(response.body, {
        status: HTTP_STATUS.INTERNAL_SERVER_ERROR,
        statusText: "Internal Server Error",
        headers: response.headers,
      });
    }
  }

  // For all other requests, continue to the page
  return next();
};
