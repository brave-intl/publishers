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
  &:hover {
    background: #fb542b;
  }
  ${(props: IButtonProps) =>
    props.enabled
      ? `
        background: #fb542b;
        cursor: pointer;
      `
      : `
      background: #9D9DB4;
      `}
`;
