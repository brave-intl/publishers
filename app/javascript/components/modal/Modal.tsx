import * as React from "react";
import * as ReactDOM from "react-dom";

import {
  Background,
  CloseIcon,
  Container,
  ExtraExtraSmallContainer,
  ExtraSmallContainer,
  LargeContainer,
  MediumContainer,
  ModalDiv,
  PaddingContainer,
  Section,
  SmallContainer,
  QrCustomContainer,
} from "./ModalStyle";

export enum ModalSize {
  ExtraExtraSmall,
  ExtraSmall,
  Small,
  Medium,
  Large,
  Auto,
  QrCustom,
}

interface IModalProps {
  show: boolean;
  padding: boolean;
  size: ModalSize;
  handleClose: any;
  children?: any;
}

export default class Modal extends React.Component<IModalProps> {
  public static defaultProps = { size: ModalSize.Auto, padding: true };
  public el: Element;
  public modalRoot = document.getElementById("modal-root");

  constructor(props) {
    super(props);
    this.el = document.createElement("div");
  }

  public componentDidMount() {
    this.modalRoot.appendChild(this.el);
  }

  public componentWillUnmount() {
    this.modalRoot.removeChild(this.el);
  }

  public componentDidUpdate() {
    // Allow users to press escape to close modal
    if (this.props.show) {
      document.addEventListener("keydown", this.escFunction, false);
    } else {
      document.removeEventListener("keydown", this.escFunction, false);
    }
  }

  public escFunction = (event) => {
    if (event.keyCode === 27) {
      this.props.handleClose();
    }
  };

  public render() {
    const childElements = (
      <PaddingContainer padding={this.props.padding}>
        <CloseIcon onClick={this.props.handleClose}>
          <svg
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              fill-rule="evenodd"
              clip-rule="evenodd"
              d="M5.99235 5.99202C5.66041 6.32397 5.66041 6.86216 5.99235 7.1941L10.7981 11.9999L5.98831 16.8097C5.65637 17.1416 5.65637 17.6798 5.98831 18.0118C6.32026 18.3437 6.85845 18.3437 7.19039 18.0118L12.0002 13.2019L16.8059 18.0077C17.1379 18.3396 17.6761 18.3396 18.008 18.0077C18.34 17.6758 18.34 17.1376 18.008 16.8056L13.2023 11.9999L18.0119 7.19025C18.3438 6.85831 18.3438 6.32012 18.0119 5.98817C17.6799 5.65623 17.1418 5.65623 16.8098 5.98817L12.0002 10.7978L7.19443 5.99202C6.86249 5.66008 6.3243 5.66008 5.99235 5.99202Z"
              fill="#62757E"
            />
          </svg>
        </CloseIcon>
        <Section className="modal-main">{this.props.children}</Section>
      </PaddingContainer>
    );

    let container = <Container>{childElements}</Container>;
    switch (this.props.size) {
      case ModalSize.ExtraExtraSmall: {
        container = (
          <ExtraExtraSmallContainer>{childElements}</ExtraExtraSmallContainer>
        );
        break;
      }
      case ModalSize.ExtraSmall: {
        container = <ExtraSmallContainer>{childElements}</ExtraSmallContainer>;
        break;
      }
      case ModalSize.Small: {
        container = <SmallContainer>{childElements}</SmallContainer>;
        break;
      }
      case ModalSize.Medium: {
        container = <MediumContainer>{childElements}</MediumContainer>;
        break;
      }
      case ModalSize.Large: {
        container = <LargeContainer>{childElements}</LargeContainer>;
        break;
      }
      case ModalSize.QrCustom: {
        container = <QrCustomContainer>{childElements}</QrCustomContainer>;
        break;
      }
    }

    // Effectively reseting the view due to how React reconcilliation works
    if (!this.props.show) {
      container = <React.Fragment />;
    }

    return (
      // Creating a portal to handle the z-index issue.
      // https://reactjs.org/docs/portals.html
      ReactDOM.createPortal(
        <ModalDiv open={this.props.show}>
          <Background onClick={this.props.handleClose} />
          {container}
        </ModalDiv>,
        this.el,
      )
    );
  }
}
