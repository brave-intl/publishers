import styled from "styled-components";

export const Wrapper = styled.div`
  min-height: calc(100vh - (190px + 2rem));
`;

export const Container = styled.div`
  max-width: 1200px;
  min-height: 600px;
  margin-left: auto;
  margin-right: auto;
  padding: 40px;
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
`;
interface IRowProps {
  campaign?: boolean;
  buttons?: boolean;
  lineBreak?: boolean;
}
export const Row = styled.div`
  display: flex;

  ${(props: IRowProps) =>
    props.campaign &&
    `
      justify-content: space-between;
    `}
    ${(props: IRowProps) =>
      props.buttons &&
      `
      justify-content: flex-end;
    `}
    ${(props: IRowProps) =>
      props.lineBreak &&
      `
      border-top: 2px solid #efefef;
      margin-top: 24px;
      margin-left: -40px;
      margin-right: -40px;
      padding-bottom: 12px;
    `}
`;

export const Button = styled.div`
  font-family: Poppins, sans-serif;
  width: 150px;
  color: black;
  text-align: center;
  border-radius: 26px;
  border: 1px solid #00000050;
  margin-top: auto;
  margin-bottom: auto;
  padding: 11px 12px 8px 12px;
  font-size: 15px;
  cursor: pointer;
  user-select: none;
`;

interface IContentProps {
  back?: boolean;
  campaignIcon?: boolean;
  closeIcon?: boolean;
  created?: boolean;
  total?: boolean;
  tableHeader?: boolean;
  buttons?: boolean;
}
export const Content = styled.div`

${(props: IContentProps) =>
  props.back &&
  `
    width: 50px;
    height: 50px;
    cursor: pointer;
    margin-top:6px;
  `}

  ${(props: IContentProps) =>
    props.campaignIcon &&
    `
    margin-top: 6px;
    width: 50px;
    height: 50px
  `}

  ${(props: IContentProps) =>
    props.closeIcon &&
    `
    width: 30px;
    height: 30px
    margin-top: -20px;
    margin-right: -10px;
  `}

  ${(props: IContentProps) =>
    props.created &&
    `
    padding-top: 12px;
    display: flex;
    ::nth-child(1) {
        color: red;
    }
  `}
  ${(props: IContentProps) =>
    props.total &&
    `
    padding-top: 8px;
    display: flex;
  `}
  ${(props: IContentProps) =>
    props.buttons &&
    `
    display: flex;
    padding-bottom: 12px;
    &:first-child {
      margin-right:12px;
    }
  `}
`;

interface ITextProps {
  header?: boolean;
  h2?: boolean;
  h4?: boolean;
  p?: boolean;
}
export const Text = styled.div`
  font-family: Poppins, sans-serif;

  ${(props: ITextProps) =>
    props.header &&
    `
      font-weight: bold;
      font-size: 15px;
      opacity: .5;
    `}

    ${(props: ITextProps) =>
      props.h2 &&
      `
      font-weight: bold;
      font-size: 26px;
    `}

    ${(props: ITextProps) =>
      props.h4 &&
      `
      font-weight: bold;
      font-size: 18px;
    `}

    ${(props: ITextProps) =>
      props.p &&
      `
      font-size: 18px;
    `}
`;
