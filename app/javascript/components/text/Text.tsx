import styled from "styled-components";

// TODO - Formalize typography at the Brave Design System level.
// This template is based on material design guidelines https://material.io/design/typography/the-type-system.html#type-scale

interface ITextProps {
  bold?: boolean;
}

export const H1 = styled.div``;

export const H2 = styled.div`
  font-size: 22px;
  ${(props: ITextProps) =>
    props.bold &&
    `
    font-weight: bold;
    `}
`;
export const H3 = styled.div``;
export const H4 = styled.div``;
export const H5 = styled.div``;
export const H6 = styled.div``;

export const P = styled.div``;

export const Subtitle = styled.div``;
export const SubtitleAlt = styled.div``;
export const Body = styled.div``;
export const BodyAlt = styled.div``;

export const ButtonText = styled.div``;
export const Caption = styled.div``;
export const Overline = styled.div``;
