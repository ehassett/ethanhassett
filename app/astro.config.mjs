// @ts-check
import { defineConfig } from "astro/config";
import node from "@astrojs/node";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  site: "https://ethanhassett.com",
  integrations: [sitemap()],
  adapter: node({
    mode: "standalone",
  }),
  vite: {
    plugins: [tailwindcss()],
  },
});
