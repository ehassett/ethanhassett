// @ts-check
import { defineConfig } from "astro/config";

import tailwind from "@astrojs/tailwind";

import node from "@astrojs/node";

import sitemap from "@astrojs/sitemap";

// https://astro.build/config
export default defineConfig({
  site: "https://ethanhassett.com",
  integrations: [tailwind(), sitemap()],
  output: "server",

  adapter: node({
    mode: "standalone",
  }),
});