import styled from "styled-components";

interface ITotalCell {
  hasBorder?: boolean;
  textRight?: boolean;
}
export const TotalCell = styled.td`
  padding-top: 0.4rem  !important;
  padding-bottom: 0.4rem  !important;

  ${(props:ITotalCell) =>
    props.hasBorder
    ? ``
    : `border: 0 !important;`}


  ${(props:ITotalCell) =>
    props.textRight
    ? `text-align: right;`
    : ``}
`

export const TableCell = styled.td`
  color: grey;
`;

export const ChannelHeader = styled.div`
  font-size: 16px;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #4b4c5c;
`;

export const Description = styled.div`
  font-size: 14px;
  font-weight: 400;
  color: grey;
`;

interface ITotalStyle {
  isDark?: boolean;
}
export const Total = styled.span`
  font-size: 15px;

  ${(props:ITotalStyle) =>
    props.isDark
      ? ``
      : `color: grey;`}
`

export const Amount = styled.h1`
  display: flex;
  align-items: baseline;
  font-size: 38px;
  color: #4c54d2;
  small {
    font-weight: 300;
    margin-left: 0.5rem;
  }
  min-width: 215px;
`;

export const Details = styled.div`
  margin-top: 4.5rem;
  color: #4b4c5c;
  font-family: "Poppins", sans-serif;
`;

export const Table = styled.table`
  color: #4b4c5c;
`;

export const Date = styled.h5`
  color: rgb(27, 29, 47);
  margin: 0;
  font-weight: normal;
`;

export const HideOverflow = styled.div`
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
`;
