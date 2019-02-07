import styled from "styled-components";

export const FlexWrapper = styled.div`
  display: flex;
`;

export const Label = styled.label`
  margin: 0;
`;

export const Input = styled.input`
  display: none;
`;

export const Header = styled.header`
  font-size: 24px;
  color: #434351;
  font-weight: 600;
  margin-bottom: 1rem;
`;

interface IButtonProps {
  enabled?: boolean;
}
export const PrimaryButton = styled.div`
  text-align: center;
  vertical-align: middle;
  border-radius: 20px;
  padding: 10px 24px;
  font-size: 12px;
  user-select: none;
  color: white;
  font-family: Poppins, sans-serif;
  ${(props: IButtonProps) =>
    props.enabled
      ? `
        background: #4c54d2;
        cursor: pointer;
      `
      : `
      background: #9D9DB4;
      `}
`;
