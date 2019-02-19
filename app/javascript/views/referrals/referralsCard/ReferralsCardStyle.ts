import styled from "styled-components";

export const FlexWrapper = styled.div`
  display: flex;
`;

export const HeaderRow = styled.div`
  margin-top: auto;
  margin-bottom: auto;
  margin-left: 16px;
`;

export const Logo = styled.div`
  height: 50px;
  width: 50px;
`;

export const SubHead = styled.div`
  display: flex;
`;

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
      margin-bottom: 28px;
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
      background-color: #f8f8f8;
      justify-content: space-between;
      grid-column-gap: 10px;
      padding: 10px 28px;
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
      `}
`;

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
        font-size: 22px;
      `}
    ${(props: ITextProps) =>
      props.use &&
      `
        font-weight: bold;
        font-size: 22px;
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
