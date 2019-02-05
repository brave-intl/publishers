import styled from "styled-components";

import { LoaderIcon } from "brave-ui/components/icons";

export const FlexWrapper = styled.div`
  display: flex;
  margin-bottom: 15px;
`;

export const Text = styled.span`
  font-family: Poppins, sans-serif;
  font-size: 14px;
  color: #4b4c5c;
`;

export const Header = styled.header`
  font-family: Poppins, sans-serif;
  text-transform: uppercase;
  font-weight: bold;
  font-size: 15px;
  color: grey;
  letter-spacing: 0.1rem;

  margin-top: auto;
  margin-bottom: auto;
  margin-right: 1rem;
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
