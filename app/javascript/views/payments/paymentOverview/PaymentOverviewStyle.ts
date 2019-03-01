import styled from "styled-components";
import { Button } from "../../style";

interface IButtonProps {
  active?: boolean;
}

export const OverviewButton = styled(Button)`
  margin-right: 15px;
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

export const Input = styled.input`
  display: none;
`;
