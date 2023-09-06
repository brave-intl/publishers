import type { Config } from 'tailwindcss';

export default {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('@brave/leo/tokens/tailwind')],
  theme: {
    borderRadius: {
      none: '0',
      '1': 'var(--leo-radius-1)',
      '2': 'var(--leo-radius-2)',
      DEFAULT: 'var(--leo-radius-8)',
      '4': 'var(--leo-radius-4)',
      '8': 'var(--leo-radius-8)',
      '16': 'var(--leo-radius-16)',
      full: '9999px',
    },
    extend: {
      // TODO: Update when Brave leo has these variables
      spacing: {
        px: '1px',
        '0.5': 'var(--leo-spacing-4)',
        '1': 'var(--leo-spacing-8)',
        '2': 'var(--leo-spacing-16)',
        '3': 'var(--leo-spacing-24)',
        '4': 'var(--leo-spacing-32)',
        '5': 'var(--leo-spacing-40)',
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
