import styled from "styled-components";
import { Header } from "../../style";

export const Link = styled.a`
  color: #4c54d2;
  font-weight: 900;
  font-size: 14px;
  margin-right: 15px;
`;

export const Title = styled.div`
  font-family: Poppins, sans-serif;
  font-size: 28px;
  color: #4b4c5c;
  margin-right: 0.5rem;
`;

export const FlexWrapper = styled.div`
  display: flex;
  margin-bottom: 15px;
`;

export const SpacedHeader = styled(Header)`
  margin-top: auto;
  margin-bottom: auto;
  margin-right: 1rem;
`;
