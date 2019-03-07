import styled from "styled-components";

interface IButtonProps {
  enabled?: boolean;
}
export const PrimaryButton = styled.div`
  text-align: center;
  vertical-align: middle;
  box-sizing: border-box;
  border-radius: 20px;
  padding: 10px 24px;
  font-size: 14px;
  user-select: none;
  color: white;
  display: inline-block;
  line-height: 1.5;
  font-family: Poppins, sans-serif;
  font-weight: 400;
  letter-spacing: 0.02em;
  &:hover {
    background: #ff1919;
  }
  ${(props: IButtonProps) =>
    props.enabled
      ? `
        background: #ff3f3f;
        border-color: #ff3f3f;
        cursor: pointer;
      `
      : `
      background: #9D9DB4;
      `}
`;
