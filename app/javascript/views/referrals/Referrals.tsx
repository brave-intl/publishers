import * as React from "react";

import { Container, Grid, Wrapper } from "./ReferralsStyle";

import ReferralsCard from "./referralsCard/ReferralsCard";
import ReferralsHeader from "./referralsHeader/ReferralsHeader";
import ReferralsNav from "./referralsNav/ReferralsNav";

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
      campaignToAddCodesTo: null,
      campaigns: [],
      codeToBeDeleted: null,
      codesToBeMoved: null,
      index: null,
      modalOpen: false,
      modalType: "Create",
      publisherID: null,
      unassigned_codes: []
    };
    this.openModal = this.openModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.openAddModal = this.openAddModal.bind(this);
    this.openDeleteModal = this.openDeleteModal.bind(this);
    this.openMoveModal = this.openMoveModal.bind(this);
    this.fetchData = this.fetchData.bind(this);
  }

  public componentDidMount() {
    this.fetchData();
  }

  public async fetchData() {
    const url = "/partners/referrals/";
    const options = {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    };
    const response = await fetch(url, options);
    const data = await response.json();
    this.setState({
      campaigns: data.campaigns,
      unassigned_codes: data.unassigned_codes
    });
  }

  public openModal(type) {
    this.setState({
      modalOpen: true,
      modalType: type
    });
  }

  public openAddModal(campaign) {
    this.setState({
      campaignToAddCodesTo: campaign,
      modalOpen: true,
      modalType: "Add"
    });
  }

  public openDeleteModal(code) {
    this.setState({
      codeToBeDeleted: code,
      modalOpen: true,
      modalType: "Delete"
    });
  }

  public openMoveModal(codes) {
    this.setState({
      codesToBeMoved: codes,
      modalOpen: true,
      modalType: "Move"
    });
  }

  public closeModal() {
    this.setState({
      modalOpen: false
    });
  }

  public refresh() {
    this.fetchData();
  }

  public render() {
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
