import styled from "styled-components";

import { LoaderIcon } from "brave-ui/components/icons";

export const FlexWrapper = styled.div`
  display: flex;
  justify-content: flex-end;
`;

export const FormElement = styled.div`
  margin-bottom: 2rem;
`;

export const Label = styled.div`
  font-weight: 600;
  margin-bottom: 0.25rem;
`;

export const Input = styled.input`
  display: none;
`;

export const ErrorText = styled.span`
  margin: auto 0 auto 1rem;
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

interface ILoadingIconProps {
  isLoading?: boolean;
}
export const LoadingIcon = styled(LoaderIcon)`
  width: 32px;

  ${(props: ILoadingIconProps) =>
    props.isLoading
      ? `
      display: inline-block;
    `
      : ` display: none;`}

  margin: auto 1rem auto;
`;
