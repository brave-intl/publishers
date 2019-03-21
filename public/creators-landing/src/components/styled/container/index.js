import styled from 'styled-components'
import React from 'react'
import { Box } from 'grommet'

// this container element acts as a faux max width
// getting the large breakpoint from grommet to behave
// is a pain and so this is easier
export const Container = styled(Box)`
  width: 100%;
  max-width: 1440px;
`

export const GradientBackground = styled(Box)`
  position: relative;
  background: linear-gradient(-45deg, #2a1fad 0%, #a91b78 100%);
  background-size: 150% 150%;
  -webkit-animation: Gradient 5s ease infinite;
  -moz-animation: Gradient 5s ease infinite;
  animation: Gradient 5s ease infinite;

  @-webkit-keyframes Gradient {
    0% {
      background-position: 0% 50%;
    }
    50% {
      background-position: 100% 50%;
    }
    100% {
      background-position: 0% 50%;
    }
  }

  @-moz-keyframes Gradient {
    0% {
      background-position: 0% 50%;
    }
    50% {
      background-position: 100% 50%;
    }
    100% {
      background-position: 0% 50%;
    }
  }

  @keyframes Gradient {
    0% {
      background-position: 0% 50%;
    }
    50% {
      background-position: 100% 50%;
    }
    100% {
      background-position: 0% 50%;
    }
  }
`

// the white swooping divider at the bottom
// sections. this svg is given a targetable id
// for the sign up/ sign in pages to fade it
export const SwoopBottom = props => (
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 1430 140'
    fill='#FFF'
    className={props.swoop || 'bottom-swoop'}
  >
    <path d='M0 140h1440V46.75C1360.635 15.583 1268.302 0 1163 0 812.13 0 674 113.78 370.736 127.279 188.866 135.374 65.286 119.625 0 80.03V140z' />
  </svg>
)

export const SwoopTop = () => (
  <svg
    viewBox='0 0 1430 140'
    className='top-swoop'
    fill='#FFF'
    xmlns='http://www.w3.org/2000/svg'
  >
    <path d='M1440 0v59.969c-65.287-39.594-188.865-55.343-370.736-47.248C766 26.221 627.87 140 277 140 171.698 140 79.365 124.417 0 93.25V0h1440z' />
  </svg>
)

export const SummaryContainer = styled(Box)`
  min-height: initial;
`

export const DividerLine = styled.div`
  border: 1px solid rgba(255, 255, 255, 0.15);
  width: 70%;
  margin: 24px 0;
`

// icon container houses all svg icons and is sized via size prop that passes
// equal width and height measurements. the svg must be specified via viewBox
// and not explicit width/height or it will not resize.
export const IconContainer = styled.svg`
  fill: ${p => p.color};
  height: ${p => p.size};
  width: ${p => p.size};
`
