import * as React from "react";

import { Wrapper, Container, Grid } from "./ReferralsStyle";

import ReferralsNav from "./referralsNav/ReferralsNav";
import ReferralsHeader from "./referralsHeader/ReferralsHeader";
import ReferralsCard from "./referralsCard/ReferralsCard";

interface IReferralsProps {
  modalType: any;
}

interface IReferralsState {
  modalType: any;
  campaigns: any;
  campaignToAddCodesTo: any;
  codeToBeDeleted: any;
  codesToBeMoved: any;
  index: any;
  unassigned_codes: any;
  modalOpen: any;
  publisherID: any;
}

export default class Referrals extends React.Component<
  IReferralsProps,
  IReferralsState
> {
  constructor(props) {
    super(props);
    this.state = {
      index: null,
      unassigned_codes: [],
      campaigns: [],
      modalOpen: false,
      modalType: "Create",
      campaignToAddCodesTo: null,
      codeToBeDeleted: null,
      codesToBeMoved: null,
      publisherID: null
    };
    this.openModal = this.openModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.openAddModal = this.openAddModal.bind(this);
    this.openDeleteModal = this.openDeleteModal.bind(this);
    this.openMoveModal = this.openMoveModal.bind(this);
    this.fetchData = this.fetchData.bind(this);
  }

  componentDidMount() {
    this.fetchData();
  }

  async fetchData() {
    let url = "/partners/referrals/";
    let options = {
      method: "GET",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    };
    let response = await fetch(url, options);
    let data = await response.json();
    this.setState({
      unassigned_codes: data.unassigned_codes,
      campaigns: data.campaigns
    });
  }

  openModal(type) {
    this.setState({
      modalOpen: true,
      modalType: type
    });
  }

  openAddModal(campaign) {
    this.setState({
      modalOpen: true,
      modalType: "Add",
      campaignToAddCodesTo: campaign
    });
  }

  openDeleteModal(code) {
    this.setState({
      modalOpen: true,
      modalType: "Delete",
      codeToBeDeleted: code
    });
  }

  openMoveModal(codes) {
    this.setState({
      modalOpen: true,
      modalType: "Move",
      codesToBeMoved: codes
    });
  }

  closeModal() {
    this.setState({
      modalOpen: false
    });
  }

  refresh() {
    console.log("refreshing");
    this.fetchData();
  }

  render() {
    return (
      <Wrapper>
        <ReferralsNav openModal={this.openModal} fetchData={this.fetchData} />
        <ReferralsContent
          openModal={this.openModal}
          campaigns={this.state.campaigns}
          unassignedCodes={this.state.unassigned_codes}
          index={this.state.index}
          openAddModal={this.openAddModal}
          openDeleteModal={this.openDeleteModal}
          openMoveModal={this.openMoveModal}
        />
      </Wrapper>
    );
  }
}

function ReferralsContent(props) {
  return (
    <Container>
      <ReferralsHeader
        campaigns={props.campaigns}
        unassignedCodes={props.unassignedCodes}
      />
      <ReferralsCardMap
        campaigns={props.campaigns}
        changeMode={props.changeMode}
      />
    </Container>
  );
}

function ReferralsCardMap(props) {
  const referralsCardMap = props.campaigns.map((campaign, index) => (
    <ReferralsCard
      key={index}
      campaign={campaign}
      changeMode={props.changeMode}
      index={index}
    />
  ));
  return <Grid>{referralsCardMap}</Grid>;
}
