import styled from "styled-components";

export const Wrapper = styled.div`
  border-radius: 6px;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;
`;

interface IContentWrapper {
  box?: boolean;
}
export const ContentWrapper = styled.div`
  display: flex;
  justify-content: space-between;

  ${(props: IContentWrapper) =>
    props.box &&
    `
      margin-top: 5px;
      margin-bottom: -15px;
      justify-content: flex-end;
    `}
`;

interface ITextWrapper {
  earnings?: boolean;
}
export const TextWrapper = styled.div`
  padding: 10px;
  ${(props: ITextWrapper) =>
    props.earnings &&
    `
      padding: 0;
      display: flex;
    `}
`;

export const Box = styled.div`
  padding: 8px 9px 6px 6px;
  margin-right: 16px;
  border-radius: 6px;
  width: 145px;
  background-color: #f1f1f9;
  display: flex;
  align-items: center;
`;

interface IText {
  box?: boolean;
  header?: boolean;
  stat?: boolean;
  bat?: boolean;
  blue?: boolean;
  purple?: boolean;
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
      font-size: 15px;
      opacity: .5;
    `}
  ${(props: IText) =>
    props.stat &&
    `
      font-weight: bold;
      font-size: 26px;
    `}
  ${(props: IText) =>
    props.bat &&
    `
      font-size: 22px;
      align-self: flex-end
      padding-bottom: 1px;
      padding-left: 6px;
    `}
  ${(props: IText) =>
    props.blue &&
    `
      color: #15A4FA;
    `}
  ${(props: IText) =>
    props.purple &&
    `
      color: #392DD1;
    `}
`;
