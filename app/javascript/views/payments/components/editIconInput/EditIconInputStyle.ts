import styled from "styled-components";

export const FlexWrapper = styled.div`
  display: flex;
  align-items: center;
`;
export const InputContainer = styled.div`
  height: 2.5rem;
  width: 15rem;
  display: flex;
  align-items: center;
`;

export const PrimaryButton = styled.div`
  text-align: center;
  vertical-align: middle;
  border-radius: 20px;
  padding: 10px 24px;
  font-size: 12px;
  user-select: none;

  color: white;
  font-family: Poppins, sans-serif;

  background: #4c54d2;
  cursor: pointer;

  margin: auto 0 auto 1rem;
`;

interface InputProps {
  testId?: string;
  icon?: React.ReactNode;
  type?: "text" | "email" | "search" | "password" | "number";
  value?: string;
  disabled?: boolean;
  onChange?: (event: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
}

export const InputComponent = styled.div<InputProps>`
  background-color: #fff;
  min-height: auto;
  box-sizing: border-box;
  width: 100%;
  border: 1px solid ${p => (p.disabled ? "#E5E5EA" : "#DFDFE8")};
  border-radius: 3px;
  padding: 8px 10px;
  &:focus-within {
    border-color: #a1a8f2;
  }
`;
export const StyledInput = styled.input<InputProps>`
  display: inline-block;
  vertical-align: middle;
  min-height: auto;
  box-sizing: border-box;
  width: calc(100% - 30px);
  max-width: 100%;
  font-size: 14px;
  font-family: Poppins, sans-serif;
  border: none;
  color: ${p => (p.disabled ? "#D1D1DB" : "#686978")};
  outline: unset;
  &::placeholder {
    color: #b8b9c4;
    font-weight: normal;
    text-align: left;
    letter-spacing: 0;
  }
`;

export const ErrorText = styled.span`
  margin: auto 0 auto 1rem;
`;

export const Text = styled.span`
  font-family: Poppins, sans-serif;
  font-size: 18px;
  color: #4b4c5c;
  margin-right: 0.5rem;
`;
