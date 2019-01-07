import styled from 'styled-components'

export const Wrapper = styled.div
`
  width: 100%;
`

export const Container = styled.div
`
  width: 1200px;
  margin-left: auto;
  margin-right: auto;

  @media (max-width: 768px) {
    width: 100%;
  }
`

export const Grid = styled.div
`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  grid-gap: 30px;
  margin-top: 30px;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
`
