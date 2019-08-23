import { LoaderIcon } from "brave-ui/components/icons";
import styled from "styled-components";

export const Header = styled.h2``;
export const TableHeader = styled.td`
  text-transform: uppercase;
  text-align: left;
  font-family: Poppins, sans-serif;
  padding: 9px 0;

  font-weight: bold;
  font-size: 11px;
  color: grey;
  letter-spacing: 0.1rem;
`;

interface ILoadingIconProps {
  isLoading?: boolean;
}
export const LoadingIcon = styled(LoaderIcon)`
  width: 32px;
  height: 32px;

  ${(props: ILoadingIconProps) =>
    props.isLoading
      ? `
      display: inline-block;
    `
      : ` display: none;`}

  margin: auto 0 auto 0;
`;
