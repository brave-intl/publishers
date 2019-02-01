import styled from "styled-components";

export const Wrapper = styled.div``;

export const Container = styled.div`
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
  padding-left: 30px;
  padding-right: 30px;
`;

export const Grid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(352px, auto));
  grid-gap: 30px;
  margin-top: 30px;
`;

export const Header = styled.header`
  font-family: Poppins, sans-serif;
  text-transform: uppercase;
  font-weight: bold;
  font-size: 15px;
  color: grey;
  letter-spacing: 0.1rem;
`;

export const Subheader = styled.span`
  font-family: Poppins, sans-serif;
  font-weight: bold;
  font-size: 15px;
  text-transform: uppercase;
  color: grey;
`;
