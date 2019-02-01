import styled from 'styled-components'

export const Wrapper = styled.div``

export const Container = styled.div
`
  max-width: 1200px;
  min-height: 600px;
  margin-left: auto;
  margin-right: auto;
  padding: 40px;
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
`

export const Row = styled.div
`
  display: flex;

  ${props => props.campaign &&
    `
      justify-content: space-between;
    `
  }
  ${props => props.buttons &&
    `
      justify-content: flex-end;
    `
  }
  ${props => props.tableHead &&
    `
      justify-content: space-between;
      padding-top: 24px;
      padding-bottom: 24px;
      border-top: 3px solid #efefef;
      border-bottom: 3px solid #efefef;

    `
  }
  ${props => props.tableRow &&
    `
      justify-content: space-between;
      padding-top: 24px;
      padding-bottom: 24px;
      border-bottom: 3px solid #efefef;

    `
  }
  ${props => props.lineBreak &&
    `
      border-top: 2px solid #efefef;
      margin-top: 24px;
      margin-left: -40px;
      margin-right: -40px;
      padding-bottom: 12px;
    `
  }
`

export const Button = styled.div
`
  font-family: Poppins, sans-serif;
  width: 150px;
  color: black;
  text-align: center;
  border-radius: 26px;
  border: 1px solid #00000050
  margin-top: auto;
  margin-bottom: auto;
  padding: 11px 12px 8px 12px;
  font-size: 15px;
  cursor: pointer;
  user-select: none;
`

export const Content = styled.div
`

${props => props.back &&
  `
    width: 50px;
    height: 50px;
    cursor: pointer;
    margin-top:6px;
  `
}

${props => props.campaignIcon &&
  `
    margin-top: 6px;
    width: 50px;
    height: 50px
  `
}

${props => props.created &&
  `
    padding-top: 12px;
    display: flex;
    ::nth-child(1) {
        color: red;
    }
  `
}
${props => props.total &&
  `
    padding-top: 8px;
    display: flex;
  `
}
${props => props.tableHeader &&
  `
    width: 150px;
    text-align: center;
  `
}
${props => props.buttons &&
  `
    display: flex;
    padding-bottom: 12px;
    &:first-child {
      margin-right:12px;
    }
  `
}
`

export const Text = styled.div
`
  font-family: Poppins, sans-serif;

  ${props => props.header &&
    `
      font-weight: bold;
      font-size: 15px;
      opacity: .5;
    `
  }

  ${props => props.h2 &&
    `
      font-weight: bold;
      font-size: 26px;
    `
  }

  ${props => props.h4 &&
    `
      font-weight: bold;
      font-size: 18px;
    `
  }

  ${props => props.p &&
    `
      font-size: 18px;
    `
  }
`
