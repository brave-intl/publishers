import styled from 'styled-components'

export const Wrapper = styled.div
`
  background-color: #A0A1B2;
  margin-top: -2rem;
  margin-bottom: 30px;
  height: 80px;
  width: 100%;
`

export const Container = styled.div
`
  display: flex;
  width: 1200px;
  height: 100%;
  margin-left: auto;
  margin-right: auto;
  justify-content: flex-end;

  @media (max-width: 768px) {
    width: 100%;
  }
`

export const Text = styled.div
`
  font-family: Poppins, sans-serif;

  ${props => props.header &&
    `
      margin-top: auto;
      margin-bottom: auto;
      font-size: 28px;
      color: white;
      padding-top: 4px;
      padding-left: 7px;
    `
  }
`

export const Button = styled.div
`
  font-family: Poppins, sans-serif;
  width: 150px;
  color: white;
  text-align: center;
  border-radius: 26px;
  border: 1px solid white;
  margin-top: auto;
  margin-bottom: auto;
  margin-left: auto;
  padding: 11px 12px 8px 12px;
  font-size: 15px;
  cursor: pointer;
  user-select: none;
`
