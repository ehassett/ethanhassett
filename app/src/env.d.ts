type Runtime = import("@astrojs/cloudflare").Runtime<Env>;

declare namespace App {
  interface Locals extends Runtime {
    contact: {
      name: {
        value: string;
        error: string;
      };
      email: {
        value: string;
        error: string;
      };
      message: {
        value: string;
        error: string;
      };
      serverError: boolean;
    };
  }
}
