/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        gov: {
          orange: '#FF6B00',
          orangeDark: '#D9531E',
          orangeLight: '#FFF4ED',
          navy: '#0B2545',
          navyDark: '#07182C',
          blue: '#134B70',
          dark: '#1E293B',
          gray: '#64748B',
          lightGray: '#F1F5F9',
          border: '#CBD5E1',
          success: '#15803D',
          warning: '#B45309',
          danger: '#B91C1C'
        }
      },
      fontFamily: {
        sans: ['Segoe UI', 'Roboto', 'Arial', 'sans-serif'],
        serif: ['Georgia', 'Cambria', 'serif']
      }
    },
  },
  plugins: [],
}
