import * as React from "react";

import { CloseStrokeIcon } from "brave-ui/components/icons";
import {
  Background,
  CloseIcon,
  Container,
  ModalDiv,
  SmallContainer,
  MediumContainer,
  LargeContainer
} from "./ModalStyle";

export enum ModalSize {
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

    return (
      <ModalDiv open={this.props.show}>
        <Background onClick={this.props.handleClose} />

        {container}
      </ModalDiv>
    );
  }
}
