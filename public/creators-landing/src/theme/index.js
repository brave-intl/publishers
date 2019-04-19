import React from 'react'
import { SwipeRightIcon, SwipeLeftIcon } from '../components'

export const theme = {
  menu: {
    extend: () => 'padding: 12px;'
  },
  global: {
    font: {
      family: 'Muli'
    },
    focus: {
      border: {
        color: 'rgba(255, 255, 255, .8)'
      },
      lineHeight: {
        value: 1.7
      }
    },
    breakpoints: {
      small: {
        value: 690
      },
      medium: {
        value: 840
      }
    }
  },
  anchor: {
    fontWeight: 400
  },
  button: {
    color: {
      light: 'white',
      dark: 'white'
    },
    border: {
      radius: '40px',
      color: '#FFFFFF'
    },
    primary: {
      color: {
        light: 'transparent',
        dark: '#fb542b'
      }
    }
  },
  heading: {
    level: {
      '1': {
        medium: {
          maxWidth: '800px'
        }
      },
      '2': {
        small: {
          size: '18px'
        }
      },
      '3': {
        small: {
          size: '16px'
        }
      }
    }
  },
  paragraph: {
    small: {
      maxWidth: '600px',
      size: '16px'
    },
    medium: {
      maxWidth: '600px'
    }
  },
  carousel: {
    icons: {
      next: () => <SwipeRightIcon />,
      previous: () => <SwipeLeftIcon />
    }
  }
}
