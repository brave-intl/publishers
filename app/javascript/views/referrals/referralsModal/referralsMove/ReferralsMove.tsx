import * as React from 'react'

import {
  Wrapper,
  Container,
  TextWrapper,
  ContentWrapper,
  TextArea,
  Button,
  Break,
  Input,
  Text
} from './ReferralsMoveStyle.ts'

import Select from 'brave-ui/components/formControls/select'
import Table, { Cell, Row } from 'brave-ui/components/dataTables/table'

import locale from '../../../locale/en.js'

export default class ReferralsMove extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
    }
  }

  handleCreate = async (e) => {
    let newCampaign = null

    if (this.state.campaignValue) {
      newCampaign = await createCampaign(this.state.campaignValue)
    }
    console.log(newCampaign.id)
    createReferralCode(this.state.codesValue, newCampaign.id)
    this.props.openModal(false)
  }

  handleCampaignValue = (e) => {
    this.setState({ campaignValue: e.target.value })
  }

  render () {

    const rows = [
      {
        content: [
          {
            content: 'Baker'
          },
          {
            content: '40%'
          }
        ]
      },
      {
        content: [
          {
            content: <div>test</div>
          },
          {
            content: '20%'
          }
        ]
      }
    ]

    const header = [
      {
        content: 'Referral Code'
      },
      {
        content: 'Description'
      }
    ]

    return (
        <Container>
            <Text heading>Move Referral Codes</Text>
            <Break/>
            <Text subtext>Number of referral codes needed</Text>
            <ContentWrapper codes>
              <Input type="number" value={this.state.codesValue} onChange={this.handleNumberOfCodes} codes/>
            </ContentWrapper>
            <Text subtext>Description</Text>
            <Input value={this.state.campaignValue} onChange={this.handleCampaignValue} name/>
            <Break/>
            <ContentWrapper buttons>
              <Button secondary onClick={() => {this.props.closeModal()}}>Cancel</Button>
              <Button solid onClick={ (e) => this.handleCreate(e) }>Create</Button>
            </ContentWrapper>
            <Table header={header} rows={rows}>abc</Table>
            {/* <CampaignDropdown campaigns={this.props.campaigns} referralCodes={this.props.codesToBeMoved}/> */}
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

function CodesList (props) {
  let header = [{ content: 'Referral Code' }, { content: 'Description' }]
  let rows = []
  return (<Table header={header} rows={rows}>Loading...</Table>)
}

// function CampaignDropdown (props) {
//   const RefCodes = props.referralCodes.map(
//     (referralCode, index) => <div key={index}>{referralCode.referral_code}</div>
//   )
//   const SelectRows = props.campaigns.map(
//     (campaign, index) => <div key={index} data-value={index}>{campaign.name}</div>
//   )
//   return (
//     <div type={'light'} floating={false} title={'hi'}>
//       {RefCodes}
//       {SelectRows}
//     </div>
//   )
// }

function CampaignInput (props) {
  return (
      <Input codes/>
  )
}

async function createReferralCode (numberOfCodes, campaignID) {
  let url = '/publishers/' + 'c1a84225-471a-4f82-8691-ab62eac7ab46' + '/referral_codes'
  let body = new FormData()
  body.append('number', numberOfCodes)
  body.append('promo_campaign_id', campaignID)
  let options = {
    method: 'POST',
    credentials: 'same-origin',
    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector('[name=csrf-token]').content }
    body: body
  }
  let response = await fetch(url, options)
  let data = await response.json()
  return data
}
