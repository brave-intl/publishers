import type { Config } from 'tailwindcss';

export default {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('@brave/leo/tokens/tailwind')],
  theme: {
    // TODO: Update when Brave leo has these variables
    borderRadius: {
      none: '0',
      '1': '1px',
      '2': '2px',
      DEFAULT: '8px',
      '4': '4px',
      '8': '8px',
      '16': '16px',
      full: '9999px',
    },
    extend: {
      colors: {
        green: '#02b999',
        red: {
          30: 'var(--leo-color-red-30)',
        },
        container: 'var(--leo-color-container-background)',
        main: 'var(--leo-color-page-background)',
      },
      // TODO: Update when Brave leo has these variables
      spacing: {
        px: '1px',
        '0.5': '4px',
        '1': '8px',
        '2': '16px',
        '3': '24px',
        '4': '32px',
        '5': '40px',
      },
      boxShadow: {
        shadow: 'var(--leo-effect-elevation-dark-01)',
      },
      keyframes: {
        flicker: {
          '0%, 19.999%, 22%, 62.999%, 64%, 64.999%, 70%, 100%': {
            opacity: '0.99',
            filter:
              'drop-shadow(0 0 1px rgba(252, 211, 77)) drop-shadow(0 0 15px rgba(245, 158, 11)) drop-shadow(0 0 1px rgba(252, 211, 77))',
          },
          '20%, 21.999%, 63%, 63.999%, 65%, 69.999%': {
            opacity: '0.4',
            filter: 'none',
          },
        },
        shimmer: {
          '0%': {
            backgroundPosition: '-700px 0',
          },
          '100%': {
            backgroundPosition: '700px 0',
          },
        },
      },
      animation: {
        flicker: 'flicker 3s linear infinite',
        shimmer: 'shimmer 1.3s linear infinite',
      },
    },
  },
} satisfies Config;
