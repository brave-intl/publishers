import styled from 'styled-components'

export const Wrapper = styled.div
`
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;
`

export const ContentWrapper = styled.div
`
  display: flex;
  justify-content: space-between;

  ${props => props.box &&
    `
      margin-top: 5px;
      margin-bottom: -15px;
      justify-content: flex-end;
    `
  }
`

export const TextWrapper = styled.div
`
  padding: 10px;
  ${props => props.earnings &&
    `
      padding: 0;
      display: flex;
    `
  }
`

export const Box = styled.div
`
  padding-bottom: 6px;
  padding-left: 6px;
  padding-right: 9px;
  padding-top: 8px;
  margin-right: 16px;
  border-radius: 6px;
  width: 145px;
  background-color: #F1F1F9;
  display: flex;
  align-items: center;
`

export const Text = styled.div
`
  font-family: Poppins, sans-serif;

  ${props => props.box &&
    `
      font-size: 17px;
      margin: auto;
    `
  }
  ${props => props.header &&
    `
      font-weight: bold;
      font-size: 15px;
      opacity: .5;
    `
  }
  ${props => props.stat &&
    `
      font-weight: bold;
      font-size: 26px;
    `
  }
  ${props => props.bat &&
    `
      font-size: 22px;
      align-self: flex-end
      padding-bottom: 1px;
      padding-left: 6px;
    `
  }
  ${props => props.blue &&
    `
      color: #15A4FA;
    `
  }
  ${props => props.purple &&
    `
      color: #392DD1;
    `
  }
`
