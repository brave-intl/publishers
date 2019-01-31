import styled from "styled-components"

export const Wrapper = styled.div`
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 24px 20px;
`

interface IContentWrapper {
  box?: boolean
}
export const ContentWrapper = styled.div`
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;

  ${(props: IContentWrapper) =>
    props.box &&
    `
    margin: 0 0 16px;
    `}
`

interface ITextWrapper {
  earnings?: boolean
}
export const TextWrapper = styled.div`
  margin: 0 18px 18px 0;

  ${(props: ITextWrapper) =>
    props.earnings &&
    `
      padding: 0;
      display: flex;
    `}
`

export const Box = styled.div`
  padding: 8px 12px;
  border-radius: 8px;
  background-color: #f1f1f9;
  display: flex;
  align-items: center;
`

interface IText {
  box?: boolean
  header?: boolean
  stat?: boolean
  bat?: boolean
  blue?: boolean
  purple?: boolean
}

export const Text = styled.div`
  font-family: Poppins, sans-serif;

  ${(props: IText) =>
    props.box &&
    `
      font-size: 17px;
      margin: auto;
    `}
  ${(props: IText) =>
    props.header &&
    `
      text-transform: uppercase;
      font-weight: bold;
      font-size: 14px;
      opacity: .7;
      letter-spacing: 1px;
      margin: 0 0 4px;
    `}
  ${(props: IText) =>
    props.stat &&
    `
      font-weight: bold;
      font-size: 26px;
      line-height: 26px;
    `}
  ${(props: IText) =>
    props.bat &&
    `
      font-size: 16px;
      margin-left: 4px;
      align-self: flex-end;
      line-height: 16px;
    `}
  ${(props: IText) =>
    props.purple &&
    `
      color: #392DD1;
    `}
`
