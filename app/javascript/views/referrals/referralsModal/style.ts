import styled from 'styled-components'

export const Wrapper = styled.div
`
  position: absolute;
  background-color: rgba(64, 64, 64, 0.7);
  top: -80px;
  left: 0px;
  height: 100vh;
  width: 100%;
  z-index: 1;

  ${({ open }) => open === false && `
    visibility: hidden;
  `}
`

export const Container = styled.div
`
  position: relative;
  margin: auto;
  top: 25%;
  transform: translateY(-25%);
  width: 700px;
  height: 600px;
  background-color: white;
  border-radius: 6px;
  padding: 80px 120px;
`

export const ContentWrapper = styled.div
`
  display: flex;

  ${props => props.codes &&
    `
      margin-top: 10px;
      margin-bottom: 10px;
    `
  }
  ${props => props.buttons &&
    `
      justify-content: flex-end;
    `
  }
`

export const Button = styled.div
`
  cursor: pointer;
  user-select: none;

  ${props => props.circle &&
    `
      border: 1px solid #4C54D2;
      border-radius: 50%;
      color: #4C54D2;
      width: 27px;
      height: 27px;
      text-align: center;
      line-height: 24px;
      font-size: 20px;
      margin-top: auto;
      margin-bottom: auto;
    `
  }
  ${props => props.solid &&
    `
      width: 150px;
      color: white;
      background-color: #4C54D2;
      text-align: center;
      border-radius: 26px;
      border: 1px solid white;
      margin-top: auto;
      margin-bottom: auto;
      padding: 11px 12px 11px 12px;
      font-size: 15px;
    `
  }
  ${props => props.secondary &&
    `
      width: 150px;
      color: #ccc;
      background-color: white;
      text-align: center;
      border-radius: 26px;
      border: 1px solid white;
      margin-top: auto;
      margin-bottom: auto;
      padding: 11px 12px 11px 12px;
      font-size: 15px;
    `
  }
`

export const Input = styled.input
`
  height: 40px;
  border: none;
  border: 1px solid #ccc;
  border-radius: 4px;

  ${props => props.codes &&
    `
      margin-left: 18px;
      margin-right: 18px;
      width: 80px;
    `
  }

  ${props => props.name &&
    `
      width: 480px;
    `
  }
`

export const TextArea = styled.textarea
`
  height: 160px;
  width: 480px;
  border: none;
  border: 1px solid #ccc;
  border-radius: 4px;
  resize: none;
`

export const Text = styled.div
`
  font-family: Poppins, sans-serif;

  ${props => props.heading &&
    `
      font-size: 26px;
      color: #4C54D2;
    `
  }

  ${props => props.subtext &&
    `
      font-size: 18px;
    `
  }

  ${props => props.description &&
    `
      font-size: 14px;
    `
  }
`

export const Break = styled.div
`
margin-top: 30px;
margin-bottom: 30px;
`
