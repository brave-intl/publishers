import styled from "styled-components";

// Implementation of a 12 column grid system.

interface ICellProps {
  startColumn: number;
  endColumn: number;
}

export const Container = styled.div`
  margin: 30px;
`;

export const Grid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  grid-gap: 30px;
`;

export const Cell = styled.div`
  ${(props: ICellProps) =>
    `
    grid-column: ${props.startColumn} / ${props.endColumn}
    `}
`;
