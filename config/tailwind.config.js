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
        // Role-based color schemes for consistent UI
        'seller': {
          50: '#F0FDF4',
          100: '#DCFCE7',
          200: '#BBF7D0',
          300: '#86EFAC',
          400: '#4ADE80',
          500: '#22C55E',
          600: '#16A34A',
          700: '#15803D',
          800: '#166534',
          900: '#14532D',
        },
        'buyer': {
          50: '#EFF6FF',
          100: '#DBEAFE',
          200: '#BFDBFE',
          300: '#93C5FD',
          400: '#60A5FA',
          500: '#3B82F6',
          600: '#2563EB',
          700: '#1D4ED8',
          800: '#1E40AF',
          900: '#1E3A8A',
        },
        'partner': {
          50: '#FFF7ED',
          100: '#FFEDD5',
          200: '#FED7AA',
          300: '#FDBA74',
          400: '#FB923C',
          500: '#F97316',
          600: '#EA580C',
          700: '#C2410C',
          800: '#9A3412',
          900: '#7C2D12',
        },
        'admin': {
          50: '#FAF5FF',
          100: '#F3E8FF',
          200: '#E9D5FF',
          300: '#D8B4FE',
          400: '#C084FC',
          500: '#A855F7',
          600: '#9333EA',
          700: '#7E22CE',
          800: '#6B21A8',
          900: '#581C87',
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
