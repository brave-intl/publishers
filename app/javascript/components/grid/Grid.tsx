import styled from "styled-components";

// Implementation of a 12 column grid system.

interface IGridProps {
  xsTemplate: string;
  smTemplate: string;
  mdTemplate: string;
  lgTemplate: string;
  xlTemplate: string;
  xsRows: string;
  smRows: string;
  mdRows: string;
  lgRows: string;
  xlRows: string;
}

interface ICellProps {
  startColumn: number;
  endColumn: number;
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

  @media (max-width: ${Breakpoint.xs}) {
    ${(props: IGridProps) =>
      `
      grid-template-areas: ${props.xsTemplate};
      grid-template-rows: ${props.xsRows};
      `}
  }

  @media (min-width: ${Breakpoint.xs}) and (max-width: ${Breakpoint.sm}) {
    ${(props: IGridProps) =>
      `
      grid-template-areas: ${props.smTemplate};
      grid-template-rows: ${props.smRows};
      `}
  }

  @media (min-width: ${Breakpoint.sm}) and (max-width: ${Breakpoint.md}) {
    ${(props: IGridProps) =>
      `
      grid-template-areas: ${props.mdTemplate};
      grid-template-rows: ${props.mdRows};
      `}
  }

  @media (min-width: ${Breakpoint.md}) and (max-width: ${Breakpoint.lg}) {
    ${(props: IGridProps) =>
      `
      grid-template-areas: ${props.lgTemplate};
      grid-template-rows: ${props.lgRows};
      `}
  }

  @media (min-width: ${Breakpoint.lg}) {
    ${(props: IGridProps) =>
      `
      grid-template-areas: ${props.xlTemplate};
      grid-template-rows: ${props.xlRows};
      `}
  }
`;

export const Cell = styled.div`
  ${(props: ICellProps) =>
    `
    grid-column: ${props.startColumn} / ${props.endColumn};
    grid-area: ${props.gridArea};
    `}
`;
