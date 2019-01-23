import styled from "styled-components";

export const Table = styled.table`
  width: 100%;
  margin-bottom: 20px;
  margin-top: 15px;
`;

export const TableHeader = styled.th`
  text-transform: uppercase;
  text-align: left;
  font-family: Poppins, sans-serif;
  line-height: 2.33;
  border-bottom: 2px solid #dedfe4;
  border-top: 2px solid #dedfe4;
  color: #4b4c5c;
  padding: 9px 0;

  font-weight: bold;
  font-size: 11px;
  color: grey;
  letter-spacing: 0.1rem;
`;

export const Cell = styled.td`
  font-family: Muli, sans-serif;
  font-size: 14px;
  font-weight: 500;
  line-height: 1.29;
  color: #686978;
  border-bottom: solid 1px #e4e8ec;
  padding: 9px 0;
  text-align: left;
  height: 42px;
`;
