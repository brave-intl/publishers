import styled from "styled-components";

interface IModalProps {
  open: boolean;
}

export const ModalDiv = styled.div`
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  height: 100vh;
  width: 100%;
  z-index: 1;

  ${(props: Partial<IModalProps>) =>
    props.open === false &&
    `
    visibility: hidden;
  `}
`;

export const Background = styled.div`
  background-color: rgba(64, 64, 64, 0.7);
  height: 100%;
  width: 100%;
  position: fixed;
  z-index: 1;
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
  z-index: 2;
`;

export const ExtraSmallContainer = styled(Container)`
  width: 33%;
  min-width: 30rem;
`;

export const SmallContainer = styled(Container)`
  width: 46%;
  min-width: 35rem;
`;

export const MediumContainer = styled(Container)`
  width: 66%;
  min-width: 35rem;
`;

export const LargeContainer = styled(Container)`
  width: 90%;
  min-width: 35rem;
`;

export const CloseIcon = styled.div`
  position: absolute;
  right: 30px;
  top: 30px;
  cursor: pointer;
  width: 24px;
  height: 24px;
`;
