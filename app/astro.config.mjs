// @ts-check
import { defineConfig } from "astro/config";
import cloudflare from "@astrojs/cloudflare";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  site: "https://ethanhassett.com",
  output: "server",
  adapter: cloudflare({
    cloudflareModules: false,
  }),
  integrations: [sitemap()],
  vite: {
    // @ts-expect-error - Vite plugin type mismatch
    plugins: [tailwindcss()],
  },
});
