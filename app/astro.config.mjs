// @ts-check
import { defineConfig } from "astro/config";
import cloudflare from "@astrojs/cloudflare";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  site: "https://ethanhassett.com",
  output: "server",
  compressHTML: true,
  session: false,
  adapter: cloudflare({
    imageService: "compile",
  }),
  integrations: [sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
});
