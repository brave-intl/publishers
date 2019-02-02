import styled from "styled-components";

import {
  CheckCircleIcon,
  CloseCircleIcon,
  PaperAirplaneIcon,
  LoaderIcon
} from "brave-ui/components/icons";

export const FlexWrapper = styled.div`
  display: flex;
`;

export const Text = styled.span`
  font-family: Poppins, sans-serif;
  font-size: 14px;
  color: #4b4c5c;
`;

export const ReportHeader = styled.header`
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

export const Approved = styled(CheckCircleIcon)`
  width: 20px;
  margin-right: 0.5rem;
`;
export const Pending = styled(PaperAirplaneIcon)`
  width: 20px;
  margin-right: 0.5rem;
  g {
    fill: #686978;
  }
`;
export const Denied = styled(CloseCircleIcon)`
  width: 20px;
  margin-right: 0.5rem;
`;

export const Status = styled.span`
  @media (max-width: 768px) {
    span {
      display: none;
    }
  }
`;
