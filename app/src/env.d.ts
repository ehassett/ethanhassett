declare namespace App {
  interface Locals {
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
