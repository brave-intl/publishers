import * as React from 'react'

import {
  Wrapper,
  Container,
  ContentWrapper,
  TextArea,
  Button,
  Break,
  Input,
  Text
} from './ReferralsCreateStyle'

import Select from 'brave-ui/components/formControls/select'

interface IReferralsModalProps {
  closeModal: any;
}

interface IReferralsModalState {
  campaignValue: any;
  codesValue: any;
  mode: any;
}

export default class ReferralsCreate extends React.Component<IReferralsModalProps, IReferralsModalState> {

  constructor (props) {
    super(props)
    this.state = {
      mode: 'dropdown',
      codesValue: 1,
      campaignValue: null
    }
  }

  handleCreate = async (e) => {
    let newCampaign = null

    if (this.state.campaignValue) {
      newCampaign = await createCampaign(this.state.campaignValue)
      createReferralCode(this.state.codesValue, newCampaign.id)
    } else {
      createReferralCode(this.state.codesValue, null)
    }
    this.props.closeModal()
  }

  handleNumberOfCodes = (e) => {
    if (e.target.value.length > 3){
      this.setState({ codesValue: e.target.value.slice(0, 3) })
    }
    else {
      this.setState({ codesValue: e.target.value })
    }
  }

  handleCampaignValue = (e) => {
    this.setState({ campaignValue: e.target.value })
  }

  handleMode = () => {
    if (this.state.mode === 'dropdown') {
      this.setState({ mode: 'input' })
    } else {
      this.setState({ mode: 'dropdown' })
    }
  }

  render () {
    return (
        <Container>
            <Text heading>Create Referral Codes</Text>
            <Break/>
            <Text subtext>Number of referral codes needed</Text>
            <ContentWrapper codes>
              <Input type="number" value={this.state.codesValue} onChange={this.handleNumberOfCodes} codes/>
            </ContentWrapper>
            <Break/>
            <Text subtext>Campaign Name</Text>
            <Input value={this.state.campaignValue} onChange={this.handleCampaignValue} name/>
            <Break/>
            <Text subtext>Description</Text>
            <Input value={this.state.campaignValue} onChange={this.handleCampaignValue} name/>
            <Break/>
            <ContentWrapper buttons>
              <Button secondary onClick={() => {this.props.closeModal()}}>Cancel</Button>
              <Button solid onClick={ (e) => this.handleCreate(e) }>Create</Button>
            </ContentWrapper>
        </Container>
    )
  }
}

function CampaignSelect (props) {

  let InputMethod = props.mode === 'dropdown' ? <CampaignDropdown campaigns={props.campaigns}/> : <Input name/>
  let InputText = props.mode === 'dropdown' ? <div>Create new campaign</div> : <div>Cancel</div>

  return (
    <div style={{ display: 'flex' }}>
      <div style={{ width: '50%' }}>
        {InputMethod}
      </div>
      <div onClick={ () => props.handleMode() } style={{ width: '50%', margin: 'auto', color: '#4C54D2', textDecoration: 'underline', userSelect: 'none', cursor:'pointer', textAlign: 'center' }}>
        {InputText}
      </div>
    </div>
  )
}

function CampaignDropdown (props) {
  const SelectRows = props.campaigns.map(
    (campaign, index) => <div key={index} data-value={index}>{campaign.name}</div>
  )
  return (
    <Select type={'light'} floating={false} title={'hi'}>
      {SelectRows}
    </Select>
  )
}

function CampaignInput (props) {
  return (
      <Input codes/>
  )
}

async function createCampaign (name) {
  let url = '/partners/referrals/create_campaign'
  let body = new FormData()
  body.append('name', name)
  let options = {
    method: 'POST',
    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").getAttribute("content") },
    body: body
  }
  let response = await fetch(url, options)
  let data = await response.json()
  return data
}

async function createReferralCode (numberOfCodes, campaignID) {
  let url = '/partners/referrals/create_codes'
  let body = new FormData()
  body.append('number', numberOfCodes)
  body.append('promo_campaign_id', campaignID)
  let options = {
    method: 'POST',
    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").getAttribute("content") },
    body: body
  }
  let response = await fetch(url, options)
  let data = await response.json()
  return data
}
