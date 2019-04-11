import styled from "styled-components";

// TODO - Formalize typography at the Brave Design System level.
// This template is based on material design guidelines https://material.io/design/typography/the-type-system.html#type-scale

interface ITextProps {
  bold?: boolean;
}

export const H1 = styled.div`
  font-family: Poppins, sans-serif;
  font-size: 30px;
`;

export const H2 = styled.div`
  font-family: Poppins, sans-serif;
  font-size: 24px;
  ${(props: ITextProps) =>
    props.bold &&
    `
    font-weight: bold;
    `}
`;
export const H3 = styled.div`
  font-size: 22px;
`;
export const H4 = styled.div`
  font-family: Poppins, sans-serif;
  font-size: 20px;
`;
export const H5 = styled.div`
  font-size: 18px;
`;
export const H6 = styled.div`
  font-size: 16px;
`;

export const P = styled.div`
  font-size: 14px;
`;

export const Subtitle = styled.div``;
export const SubtitleAlt = styled.div``;
export const Body = styled.div``;
export const BodyAlt = styled.div``;

export const ButtonText = styled.div``;
export const Caption = styled.div``;
export const Overline = styled.div``;
