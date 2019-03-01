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

export const FlexWrapper = styled.div`
  display: flex;
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

export const Card = styled.div`
  border-radius: 6px;
  display: grid;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;
`;

export const Table = styled.table`
  width: 100%;
`;

export const TableHeader = styled.th`
  text-transform: uppercase;
  text-align: left;
  font-family: Poppins, sans-serif;
  line-height: 2.33;
  border-bottom: 2px solid #dedfe4;
  border-top: 2px solid #dedfe4;
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

interface IButtonProps {
  inactive?: boolean;
}

export const Button = styled.div`
  text-align: center;
  vertical-align: middle;
  border-radius: 20px;
  padding: 10px 24px;
  font-size: 12px;
  user-select: none;

  font-family: Poppins, sans-serif;
  font-weight: 900;
  letter-spacing: 0.39px;

  ${(props: IButtonProps) =>
    props.inactive
      ? `
        border: 1px solid #EDEDF0;
        color: #eDEDF0;
      `
      : `
        border: 1px solid #a1a8f2;
        color: #4c54d2;
        cursor: pointer;
    `}
`;

export const FormControl = styled.div`
  margin-bottom: 1.5rem;
`;
