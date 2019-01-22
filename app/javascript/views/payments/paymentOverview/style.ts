import styled from "styled-components";

export const Button = styled.div`
  color: #4c54d2;
  text-align: center;
  height: 40px;
  border-radius: 20px;
  border: 1px solid #a1a8f2;
  padding: 10px 24px;
  font-size: 15px;
  cursor: pointer;
  user-select: none;

  font-family: Poppins, sans-serif;
  font-weight: 600;
  letter-spacing: 0.39px;
`;

export const Card = styled.div`
  border-radius: 6px;
  display: grid;
  background-color: white;
  box-shadow: rgba(99, 105, 110, 0.18) 0px 1px 12px 0px;
  padding: 30px;
`;

export const Text = styled.span`
  font-family: Poppins, sans-serif;
  font-size: 28px;
  color: #4b4c5c;
`;

export const ButtonGroup = styled.div`
  display: flex;
`;
