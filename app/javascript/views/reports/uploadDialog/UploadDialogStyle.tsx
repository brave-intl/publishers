import styled from "styled-components";

import { LoaderIcon } from "brave-ui/components/icons";

export const FlexWrapper = styled.div`
  display: flex;
`;

export const Label = styled.label`
  margin: 0;
`;

export const Input = styled.input`
  display: none;
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

  margin: auto 0 auto 1rem;
`;

export const ErrorText = styled.span`
  margin: auto 0 auto 1rem;
`;
