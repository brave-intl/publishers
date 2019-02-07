import * as React from "react";

import { Wrapper } from "./ReferralsModalStyle";

import ReferralsCreate from "./referralsCreate/ReferralsCreate";

import locale from "../../../locale/en.js";

interface IReferralsModalProps {
  openModal: any;
  closeModal: any;
  modalOpen: any;
  modalType: any;
  campaigns: any;
  maxCodes: any;
  campaignToAddCodesTo: any;
  codeToBeDeleted: any;
  codesToBeMoved: any;
  refresh: any;
}

export default class ReferralsModal extends React.Component<
  IReferralsModalProps
> {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <Wrapper open={this.props.modalOpen}>
        <ReferralsModalType
          modalType={this.props.modalType}
          openModal={this.props.openModal}
          closeModal={this.props.closeModal}
          campaignToAddCodesTo={this.props.campaignToAddCodesTo}
          codeToBeDeleted={this.props.codeToBeDeleted}
          codesToBeMoved={this.props.codesToBeMoved}
          campaigns={this.props.campaigns}
          refresh={this.props.refresh}
        />
      </Wrapper>
    );
  }
}

function ReferralsModalType(props) {
  switch (props.modalType) {
    case "Create":
      return <ReferralsCreate closeModal={props.closeModal} />;
      break;
  }
}
