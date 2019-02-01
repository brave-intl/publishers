import styled from "styled-components";
import { checkPropTypes } from "prop-types";

interface IModalProps {
  open: boolean;
}

export const ModalDiv = styled.div`
  position: absolute;
  top: -80px;
  left: 0px;
  height: 100vh;
  width: 100%;
  z-index: 9001;

  ${(props: Partial<IModalProps>) =>
    props.open === false &&
    `
    visibility: hidden;
  `}
`;

export const Background = styled.div`
  background-color: rgba(64, 64, 64, 0.7);
  height: 100vh;
  width: 100%;
  position: absolute;
`;

enum ModalSize {
  Small,
  Medium,
  Large,
  Auto
}

interface IContainerProps {
  size: ModalSize;
}
export const Container = styled.div`
  position: relative;
  margin: auto;
  top: 25%;
  transform: translateY(-25%);
  background-color: white;
  border-radius: 6px;
  padding: 50px;
`;

export const SmallContainer = styled(Container)`
  width: 30%;
  min-width: 25rem;
`;

export const MediumContainer = styled(Container)`
  width: 60%;
  min-width: 25rem;
`;

export const LargeContainer = styled(Container)`
  width: 90%;
  min-width: 30rem;
`;

export const CloseIcon = styled.div`
  position: absolute;
  right: 30px;
  top: 30px;
  cursor: pointer;
  width: 24px;
  height: 24px;
`;
