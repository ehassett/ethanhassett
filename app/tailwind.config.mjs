/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        "dark-100": "#495057",
        "dark-200": "#3f454c",
        "dark-300": "#343a40",
        "dark-400": "#2b3035",
        "dark-500": "#212529",
        "light-100": "#f8f9fa",
        "light-200": "#e9ecef",
        "light-300": "#dee2e6",
        "light-400": "#ced4da",
        "light-500": "#adb5bd",
      },
      fontFamily: {
        "departure-mono": ["Departure Mono", "monospace"],
      },
    },
  },
  plugins: [],
};
