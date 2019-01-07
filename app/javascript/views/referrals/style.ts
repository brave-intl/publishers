import styled from 'styled-components'

export const Wrapper = styled.div
`
  width: 100%;
`

export const Container = styled.div
`
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;

  @media (max-width: 768px) {
    width: 100%;
  }
`

export const Grid = styled.div
`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(352px, auto));
  grid-gap: 30px;
  margin-top: 30px;
`
