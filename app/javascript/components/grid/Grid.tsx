import styled from "styled-components";

// Implementation of a 12 column grid system.

interface IGridProps {
  templateAreas: string;
  templateRows: string;
}

interface ICellProps {
  gridArea: string;
}

enum Breakpoint {
  xs = "576px",
  sm = "768px",
  md = "992px",
  lg = "1200px"
}

export const Container = styled.div`
  margin: auto;
  @media (max-width: ${Breakpoint.xs}) {
    max-width: ${Breakpoint.xs};
  }
  @media (min-width: ${Breakpoint.xs}) and (max-width: ${Breakpoint.sm}) {
    max-width: ${Breakpoint.xs};
  }
  @media (min-width: ${Breakpoint.sm}) and (max-width: ${Breakpoint.md}) {
    max-width: ${Breakpoint.sm};
  }
  @media (min-width: ${Breakpoint.md}) and (max-width: ${Breakpoint.lg}) {
    max-width: ${Breakpoint.md};
  }
  @media (min-width: ${Breakpoint.lg}) {
    max-width: ${Breakpoint.lg};
  }
`;

export const Grid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  grid-gap: 30px;
  ${(props: IGridProps) =>
    `
    grid-template-areas: ${props.templateAreas};
    grid-template-rows: ${props.templateRows};
    `}
`;

export const Cell = styled.div`
  ${(props: ICellProps) =>
    `
    grid-area: ${props.gridArea};
    `}
`;
