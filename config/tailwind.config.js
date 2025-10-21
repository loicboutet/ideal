const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'ideal': {
          'primary': '#4A90E2',
          'primary-dark': '#3A7BC8',
          'secondary': '#D4D4D4',
          'accent': '#FFD700',
          'success': '#7FBF5F',
          'danger': '#E74C3C',
          'warning': '#F39C12',
        },
        'ideal-text': {
          'dark': '#2C3E50',
          'medium': '#7F8C8D',
          'light': '#BDC3C7',
        },
        'ideal-bg': {
          'light': '#F8F9FA',
          'white': '#FFFFFF',
        },
        'ideal-border': {
          'light': '#E0E0E0',
          'medium': '#CCCCCC',
        },
      },
      boxShadow: {
        'card': '0 2px 8px rgba(0, 0, 0, 0.08)',
      },
      borderRadius: {
        'ideal-sm': '4px',
        'ideal-md': '8px',
        'ideal-lg': '12px',
      },
    },
  },
  plugins: [
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ]
}
