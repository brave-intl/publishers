import styled from "styled-components";

interface IStatusIconProps {
  active?: boolean;
}

export const StatusIcon = styled.i`
  width: 12px;
  height: 12px;
  display: inline-block;
  border-radius: 50%;
  margin-right: 5px;

  ${(props: IStatusIconProps) =>
    props.active
      ? `
      background: #14cd87;
      `
      : `
      background: #d1d1da;
    `}
`;

export const NotConnected = styled.span`
  color: #fc4145;
  font-weight: bold;
  margin-right: 1em;
`;
