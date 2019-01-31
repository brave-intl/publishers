import styled from "styled-components"

export const Wrapper = styled.div`
  border-radius: 6px;
  background-color: white;
  padding: 24px 20px;
`

export const Grid = styled.div``

interface IRowProps {
  title?: boolean
  stats?: boolean
  total?: boolean
  check?: boolean
  carat?: boolean
}
export const Row = styled.div`
  display: flex;
  align-items: center;


  ${props =>
    props.title &&
    `
      margin-bottom: 24px;
    `}

  ${(props: IRowProps) =>
    props.stats &&
    `
      margin-top: 20px;
      padding-bottom: 15px;
      justify-content: space-between;
    `}

  ${(props: IRowProps) =>
    props.total &&
    `
      background-color: #F1F1F9;
      padding: 12px 24px;
      margin-left: -20px;
      margin-right: -20px;
      margin-bottom: -24px;
      border-bottom-right-radius: 6px;
      border-bottom-left-radius: 6px;
    `}
`

interface IIconWrapperProps {
  check?: boolean
  carat?: boolean
}
export const IconWrapper = styled.div`
  ${(props: IIconWrapperProps) =>
    props.check &&
    `
        width: 52px;
        height: 52px;
      `}
  ${(props: IIconWrapperProps) =>
    props.carat &&
    `
        width: 32px;
        height: 32px;
        margin-left: auto;
      `}
`

interface ITextWrapper {
  created?: boolean
  carat?: boolean
  stats?: boolean
  total?: boolean
}
export const TextWrapper = styled.div`
    ${(props: ITextWrapper) =>
      props.created &&
      `
        display: flex;
      `}
    ${props =>
      props.carat &&
      `
        width: 40px;
        height: 40px;
        display: inline-block;
      `}
    ${props =>
      props.stats &&
      `
        padding: 10px;
      `}
    ${props =>
      props.total &&
      `
        padding: 10px;
      `}
`

export const ContentWrapper = styled.div`
  padding: 10px;
`

export const Image = styled.div

interface ITextProps {
  title?: boolean
  created?: boolean
  date?: boolean
  header?: boolean
  stat?: boolean
  use?: boolean
  total?: boolean
  codes?: boolean
}
export const Text = styled.div`
  font-family: Poppins, sans-serif;

    ${(props: ITextProps) =>
      props.title &&
      `
          font-weight: bold;
          font-size: 22px;
      `}
    ${(props: ITextProps) =>
      props.created &&
      `
        font-weight: bold;
        font-size: 14px;
        padding-right: 10px;
      `}
    ${(props: ITextProps) =>
      props.date &&
      `
        font-size: 14px;
      `}
    ${(props: ITextProps) =>
      props.header &&
      `
        text-transform: uppercase;
        font-weight: bold;
        font-size: 15px;
        opacity: .5;
      `}
    ${(props: ITextProps) =>
      props.stat &&
      `
        font-weight: bold;
        font-size: 20px;
      `}
    ${(props: ITextProps) =>
      props.use &&
      `
        font-weight: bold;
        font-size: 20px;
        color: #4C54D2;
      `}
    ${(props: ITextProps) =>
      props.total &&
      `
        font-weight: bold;
        font-size: 16px;
        opacity: .7;
        display: inline-block;
      `}
    ${(props: ITextProps) =>
      props.codes &&
      `
        font-weight: bold;
        font-size: 18px;
        display: inline-block;
      `}
`
