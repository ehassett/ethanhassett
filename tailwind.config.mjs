/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        "oxford-blue": "#001D3D",
        "mikado-yellow": "#FFC300",
      },
      fontFamily: {
        arvo: ["Arvo", "serif"],
        "source-code-pro": ["Source Code Pro", "monospace"],
      },
      screens: {
        "3xl": "1792px",
      },
    },
  },
  plugins: [],
};
