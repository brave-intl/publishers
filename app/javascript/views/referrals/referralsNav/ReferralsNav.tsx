import * as React from "react";

import { Button, Container, Text, Wrapper } from "./ReferralsNavStyle";

import Modal, { ModalSize } from "../../../components/modal/Modal";
import CreateDialog from "./createDialog/CreateDialog";

import locale from "../../../locale/en";

interface IReferralsNavProps {
  fetchData: any;
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

  public render() {
    return (
      <Wrapper>
        <Container>
          <Text header>{locale.referrals.referrals}</Text>
          <Button
            onClick={() => {
              this.triggerCreateModal();
            }}
          >
            {locale.referrals.createCampaign}
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
