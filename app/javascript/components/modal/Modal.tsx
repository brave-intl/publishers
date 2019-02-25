import * as React from "react";
import * as ReactDOM from "react-dom";

import { CloseStrokeIcon } from "brave-ui/components/icons";
import {
  Background,
  CloseIcon,
  Container,
  ExtraSmallContainer,
  LargeContainer,
  MediumContainer,
  ModalDiv,
  SmallContainer
} from "./ModalStyle";

export enum ModalSize {
  ExtraSmall,
  Small,
  Medium,
  Large,
  Auto
}

interface IModalProps {
  show: boolean;
  size: ModalSize;
  handleClose: () => void;
  children?: any;
}

export default class Modal extends React.Component<IModalProps> {
  public static defaultProps = { size: ModalSize.Auto };
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

  public escFunction = event => {
    if (event.keyCode === 27) {
      this.props.handleClose();
    }
  };

  public render() {
    const childElements = (
      <React.Fragment>
        <CloseIcon>
          <CloseStrokeIcon onClick={this.props.handleClose} />
        </CloseIcon>
        <section className="modal-main">{this.props.children}</section>
      </React.Fragment>
    );

    let container = <Container>{childElements}</Container>;
    switch (this.props.size) {
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
        this.el
      )
    );
  }
}