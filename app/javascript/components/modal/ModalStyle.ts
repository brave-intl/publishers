import styled from "styled-components";

interface IModalProps {
  open: boolean;
}

export const ModalDiv = styled.div`
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  height: 100%;
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
  Auto,
  ExtraExtraSmall,
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
  z-index: 2;
`;

interface IPaddingContainer {
  padding: boolean;
}
export const PaddingContainer = styled.div`
  ${(props: Partial<IPaddingContainer>) =>
    props.padding === true &&
    `
    padding: 15px;

    @media only screen and (min-width: 768px) {
      padding: 50px;
    }
  `}
`;

export const ExtraExtraSmallContainer = styled(Container)`
  width: 95%;
  min-width: 420px;
  border-radius: 16px;

  @media only screen and (min-width: 600px) {
    max-width: 420px;
  }
  @media only screen and (min-width: 768px) {
    max-width: 420px;
  }
`;

export const ExtraSmallContainer = styled(Container)`
  width: 95%;
  min-width: 20rem;

  @media only screen and (min-width: 600px) {
    min-width: 30rem;
  }
  @media only screen and (min-width: 768px) {
    min-width: 33rem;
    width: 33%;
  }
`;

export const SmallContainer = styled(Container)`
  width: 95%;
  min-width: 20rem;

  @media only screen and (min-width: 600px) {
    min-width: 30rem;
  }
  @media only screen and (min-width: 768px) {
    width: 46%;
    min-width: 35rem;
  }
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
  right: 15px;
  top: 15px;
  cursor: pointer;
  width: 24px;
  height: 24px;
`;

export const Section = styled.section`
  max-height: 80vh;
  overflow-y: auto;
`;
