import styled from "styled-components";

export const Button = styled.div`
  color: #4c54d2;
  text-align: center;
  vertical-align: middle;
  border-radius: 20px;
  border: 1px solid #a1a8f2;
  padding: 10px 24px;
  font-size: 14px;
  cursor: pointer;
  user-select: none;

  font-family: Poppins, sans-serif;
  font-weight: 600;
  letter-spacing: 0.39px;

  // For the padding
  margin-right: 15px;
`;

export const Text = styled.span`
  font-family: Poppins, sans-serif;
  font-size: 28px;
  color: #4b4c5c;
`;

export const ButtonGroup = styled.div`
  display: flex;
`;

export const Wrapper = styled.div`
  display: grid;
  grid-row-gap: 30px;
`;
