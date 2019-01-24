import styled from "styled-components";

interface IButtonProps {
  active?: boolean;
}

export const Button = styled.div`
  text-align: center;
  vertical-align: middle;
  border-radius: 20px;
  padding: 8px 24px;
  font-size: 12px;
  user-select: none;

  font-family: Poppins, sans-serif;
  font-weight: 900;
  letter-spacing: 0.39px;

  margin-right: 15px;
  ${(props: IButtonProps) =>
    props.active
      ? `
      border: 1px solid #a1a8f2;
      color: #4c54d2;
      cursor: pointer;
      `
      : `
        border: 1px solid #EDEDF0;
        color: #eDEDF0;
    `}
`;

export const Text = styled.span`
  font-family: Poppins, sans-serif;
  font-size: 28px;
  color: #4b4c5c;
`;

export const InactiveText = styled.span`
  font-family: Poppins, sans-serif;
  font-size: 16px;
  color: #d1d1db;
`;

export const PaymentTotal = styled.div`
  margin-bottom: 10px;
`;

export const ButtonGroup = styled.div`
  display: flex;
`;

export const Wrapper = styled.div`
  display: grid;
  grid-row-gap: 30px;
`;
