import styled from "styled-components";

export const Layout = styled.div`
  display: grid;
  grid-row-gap: 30px;
`;

export const Row = styled.div`
  display: grid;
  grid-column-gap: 30px;
  grid-row-gap: 30px;
  @media (min-width: 900px) {
    grid-template-columns: 2fr 1fr;
  }
  @media (max-width: 900px) {
    grid-template-columns: 1fr;
  }
`;

export const Card = styled.div`
  border-radius: 6px;
  display: grid;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;
`;
