import * as React from 'react'

import {
  Wrapper,
  Container,
  Grid
} from './ReferralsStyle'

import ReferralsNav from './referralsNav/ReferralsNav'
import ReferralsModal from './referralsModal/ReferralsModal'
import ReferralsHeader from './referralsHeader/ReferralsHeader'
import ReferralsCard from './referralsCard/ReferralsCard'
import ReferralsInfo from './referralsInfo/ReferralsInfo'
import { any } from 'prop-types';

interface IReferralsProps {
  modalType: any;
}

interface IReferralsState {
  modalType: any;
  campaigns: any;
  campaignToAddCodesTo: any;
  codeToBeDeleted: any;
  codesToBeMoved: any;
  mode: any;
  index: any;
  unassigned_codes: any;
  modalOpen: any;
  publisherID: any;
}

export default class Referrals extends React.Component<IReferralsProps, IReferralsState> {

  constructor (props) {
    super(props)
    this.state = {
      mode: 'grid',
      index: null,
      unassigned_codes: [],
      campaigns: [],
      modalOpen: false,
      modalType: 'Create',
      campaignToAddCodesTo: null,
      codeToBeDeleted: null,
      codesToBeMoved: null,
      publisherID: null,
    }
    this.openModal = this.openModal.bind(this)
    this.closeModal = this.closeModal.bind(this)
    this.openAddModal = this.openAddModal.bind(this)
    this.openDeleteModal = this.openDeleteModal.bind(this)
    this.openMoveModal = this.openMoveModal.bind(this)
    this.refresh = this.refresh.bind(this)
  }

  componentDidMount () {
    this.fetchData()
  }

  async fetchData () {
    // add publisher id
    let url = '/partners/referrals'
    let options = {
      method: 'GET',
      headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest'}
    }
    let response = await fetch(url, options)
    let data = await response.json()
    this.setState({ unassigned_codes: data.unassigned_codes, campaigns: data.campaigns })
  }

  openModal (type) {
    this.setState({
      modalOpen: true,
      modalType: type
    })
  }

  openAddModal (campaign) {
    this.setState({
      modalOpen: true,
      modalType: 'Add',
      campaignToAddCodesTo: campaign
    })
  }

  openDeleteModal (code) {
    this.setState({
      modalOpen: true,
      modalType: 'Delete',
      codeToBeDeleted: code
    })
  }

  openMoveModal (codes) {
    this.setState({
      modalOpen: true,
      modalType: 'Move',
      codesToBeMoved: codes
    })
  }

  closeModal () {
    this.setState({
      modalOpen: false
    })
  }

  changeMode = (mode, index) => {
    this.setState({
      mode: mode,
      index: index
    })
  }

  refresh () {
    console.log('refreshing')
    this.fetchData()
  }

  render () {
    return (
      <Wrapper>
        <ReferralsNav openModal={this.openModal}/>
        <ReferralsModal openModal={this.openModal} modalOpen={this.state.modalOpen} closeModal={this.closeModal} modalType={this.state.modalType} campaigns={this.state.campaigns} maxCodes={400} campaignToAddCodesTo={this.state.campaignToAddCodesTo} codeToBeDeleted={this.state.codeToBeDeleted} codesToBeMoved={this.state.codesToBeMoved} refresh={this.refresh}/>
        <ReferralsContent openModal={this.openModal} mode={this.state.mode} campaigns={this.state.campaigns} changeMode={this.changeMode} index={this.state.index} openAddModal={this.openAddModal} openDeleteModal={this.openDeleteModal} openMoveModal={this.openMoveModal}/>
      </Wrapper>
    )
  }
}

// function processData (promoCampaignsData, promoRegistrationsData) {
//
// }

function ReferralsContent (props) {
  switch (props.mode) {
    case 'single':
      return (
        <Container>
          <ReferralsInfo openModal={props.openModal} campaign={props.campaigns[props.index]} changeMode={props.changeMode} openAddModal={props.openAddModal} openDeleteModal={props.openDeleteModal} openMoveModal={props.openMoveModal}/>
        </Container>
      )
      break
    case 'grid':
      return (
        <Container>
          <ReferralsHeader/>
          <ReferralsCardMap campaigns={props.campaigns} changeMode={props.changeMode}/>
        </Container>
      )
      break
  }
}

function ReferralsCardMap (props) {
  const referralsCardMap = props.campaigns.map(
    (campaign, index) => <ReferralsCard key={index} campaign={campaign} changeMode={props.changeMode} index={index}/>
  )
  return <Grid>{referralsCardMap}</Grid>
}
