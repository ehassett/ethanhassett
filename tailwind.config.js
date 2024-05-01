/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        light: {
          100: "#f8f9fa",
          200: "#e9ecef",
          300: "#dee2e6",
          400: "#ced4da",
          500: "#adb5bd",
        },
        dark: {
          100: "#495057",
          200: "#3f454c",
          300: "#343a40",
          400: "#2b3035",
          500: "#212529",
        }
      },
    },
  },
  plugins: [],
};
