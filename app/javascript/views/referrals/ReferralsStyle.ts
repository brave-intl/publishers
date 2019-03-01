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
  grid-template-columns: repeat(auto-fill, minmax(358px, auto));
  grid-gap: 30px;
  margin-top: 30px;
`;
