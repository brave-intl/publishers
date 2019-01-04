import styled from 'styled-components'

export const Wrapper = styled.div
`
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;
`

export const Grid = styled.div``

export const TitleWrapper = styled.div
`
  display: flex;
  margin-bottom: 30px;
`

export const StatsWrapper = styled.div
`
  display: flex;
  margin-top: 20px;
  padding-bottom: 15px;
  justify-content: space-between;
`

export const TotalWrapper = styled.div
`
  display: flex;
  justify-content: space-between;
  grid-column-gap: 10px;
  background-color: #F1F1F9;
  padding-top: 10px;
  padding-bottom: 10px;
  padding-left: 30px;
  padding-right: 30px;
  margin-left: -30px;
  margin-right: -30px;
  margin-bottom: -30px;
  border-bottom-right-radius: 6px;
  border-bottom-left-radius: 6px;
`

export const IconWrapper = styled.div
`
    ${props => props.check &&
      `
        margin-left: 10px;
        margin-top: 6px;
        margin-bottom: 10px;
        width: 60px;
        height: 60px;
      `
    }
    ${props => props.carat &&
      `
        width: 40px;
        height: 40px;
        padding-top: 4.5px;
      `
    }
`

export const TextWrapper = styled.div
`
    ${props => props.created &&
      `
        display: flex;
      `
    }
    ${props => props.carat &&
      `
        width: 40px;
        height: 40px;
        display: inline-block;
      `
    }
    ${props => props.stats &&
      `
        padding: 10px;
      `
    }
    ${props => props.total &&
      `
        padding: 10px;
      `
    }
`

export const ContentWrapper = styled.div
`
  padding: 10px;

`

export const Image = styled.div

export const Text = styled.div
`
  font-family: Poppins, sans-serif;

    ${props => props.title &&
      `
          font-weight: bold;
          font-size: 22px;
      `
    }
    ${props => props.created &&
      `
        font-weight: bold;
        font-size: 14px;
        padding-right: 10px;
      `
    }
    ${props => props.date &&
      `
        font-size: 14px;
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
        font-size: 20px;
      `
    }
    ${props => props.use &&
      `
        font-weight: bold;
        font-size: 20px;
        color: #4C54D2;
      `
    }
    ${props => props.total &&
      `
        font-weight: bold;
        font-size: 16px;
        opacity: .7;
        display: inline-block;
      `
    }
    ${props => props.codes &&
      `
        font-weight: bold;
        font-size: 18px;
        display: inline-block;
      `
    }

`
