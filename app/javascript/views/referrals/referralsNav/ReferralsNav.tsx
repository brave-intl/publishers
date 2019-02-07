import * as React from "react";

import { Wrapper, Container, Text, Button } from "./ReferralsNavStyle";

import Modal, { ModalSize } from "../../../components/modal/Modal";
import CreateDialog from "./createDialog/CreateDialog";

import locale from "../../../locale/en";

interface IReferralsNavProps {
  openModal: (type: any) => void;
}

interface IReferralsNavState {
  showCreateModal: boolean;
}

export default class ReferralsNav extends React.Component<
  IReferralsNavProps,
  IReferralsNavState
> {
  constructor(props) {
    super(props);
    this.state = {
      showCreateModal: false
    };
  }

  render() {
    return (
      <Wrapper>
        <Container>
          <Text header>{locale.referrals}</Text>
          <Button
            onClick={() => {
              this.triggerCreateModal();
            }}
          >
            {locale.createCode}
          </Button>
          <Modal
            handleClose={this.triggerCreateModal}
            show={this.state.showCreateModal}
            size={ModalSize.ExtraSmall}
          >
            <CreateDialog
              closeModal={this.triggerCreateModal}
              afterSave={this.props.fetchData}
            />
          </Modal>
        </Container>
      </Wrapper>
    );
  }
  private triggerCreateModal = () => {
    this.setState({ showCreateModal: !this.state.showCreateModal });
  };
}
