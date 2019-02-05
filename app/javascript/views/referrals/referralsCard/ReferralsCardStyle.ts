import styled from "styled-components";

export const Wrapper = styled.div`
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;
`;

export const Grid = styled.div``;

interface IRowProps {
  title?: boolean;
  stats?: boolean;
  total?: boolean;
  check?: boolean;
  carat?: boolean;
}
export const Row = styled.div`
  display: flex;


  ${props =>
    props.title &&
    `
      margin-bottom: 30px;
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
      justify-content: space-between;
      grid-column-gap: 10px;
      background-color: #F1F1F9;
      padding: 10px 30px;
      margin-left: -28px;
      margin-right: -28px;
      margin-bottom: -28px;
      border-bottom-right-radius: 6px;
      border-bottom-left-radius: 6px;
    `}
`;

interface IIconWrapperProps {
  check?: boolean;
  carat?: boolean;
}
export const IconWrapper = styled.div`
  ${(props: IIconWrapperProps) =>
    props.check &&
    `
        margin-left: 10px;
        margin-top: 6px;
        margin-bottom: 10px;
        width: 60px;
        height: 60px;
      `}
  ${(props: IIconWrapperProps) =>
    props.carat &&
    `
        width: 40px;
        height: 40px;
        padding-top: 4.5px;
        cursor: pointer;
      `
    }
`

interface ITextWrapper {
  created?: boolean;
  carat?: boolean;
  stats?: boolean;
  total?: boolean;
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
`;

export const ContentWrapper = styled.div`
  padding: 10px;
`;

export const Image = styled.div;

interface ITextProps {
  title?: boolean;
  created?: boolean;
  date?: boolean;
  header?: boolean;
  stat?: boolean;
  use?: boolean;
  total?: boolean;
  codes?: boolean;
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
`;
