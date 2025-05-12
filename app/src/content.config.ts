import { defineCollection, z } from "astro:content";
import { glob } from "astro/loaders";

const experience = defineCollection({
  loader: glob({ pattern: ["*.md"], base: "src/content/experience" }),
  schema: z.object({
    title: z.string(),
    company: z.string(),
    start: z.coerce.date(),
    end: z.coerce.date().optional(),
  }),
});

const certifications = defineCollection({
  loader: glob({ pattern: ["*.md"], base: "src/content/certifications" }),
  schema: z.object({
    title: z.string(),
    issuer: z.string(),
    expires: z.coerce.date(),
    link: z.string(),
  }),
});

const skills = defineCollection({
  loader: glob({ pattern: ["*.md"], base: "src/content/skills" }),
  schema: z.object({
    items: z.array(z.string()),
  }),
});

const languages = defineCollection({
  loader: glob({ pattern: ["*.md"], base: "src/content/languages" }),
  schema: z.object({
    language: z.string(),
    level: z.enum(["A1", "A2", "B1", "B2", "C1", "C2", "Native"]),
  }),
});

export const collections = { experience, certifications, skills, languages };
