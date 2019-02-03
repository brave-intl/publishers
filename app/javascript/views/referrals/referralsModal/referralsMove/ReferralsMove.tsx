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
} from './ReferralsMoveStyle'

import Checkbox from 'brave-ui/components/formControls/checkbox'
import Table, { Cell, Row } from 'brave-ui/components/dataTables/table'

interface IReferralsModalProps {
  closeModal: any;
  codesToBeMoved: any;
  refresh: any;
  campaigns: any;
}

interface IReferralsModalState {
  selectedCodes: any;
  selectedCampaign: any;
  campaignValue: any;
  codesValue: any;
}


export default class ReferralsMove extends React.Component<IReferralsModalProps, IReferralsModalState> {

  constructor (props) {
    super(props)
    this.state = {
      selectedCodes: [],
      selectedCampaign: null,
      campaignValue: null,
      codesValue: null
    }
  }

  handleCreate = async (e) => {
    let newCampaign = null

    if (this.state.campaignValue) {
    }
    createReferralCode(this.state.codesValue, newCampaign.id)
    // this.props.openModal(false)
  }

  handleCampaignValue = (e) => {
    this.setState({ campaignValue: e.target.value })
  }

  handleCodeSelect = (e, id) => {
    // alert('selected!' + id + ' ' + e.target.checked)
    let temp = this.state.selectedCodes
  }

  handleCampaignSelect = (e) => {

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
            {/* <CodesList referralCodes={this.props.codesToBeMoved} handleCodeSelect={this.handleCodeSelect}/> */}
            <Break/>
            <CampaignDropdown campaigns={this.props.campaigns}/>
            <Break/>
            <ContentWrapper buttons>
              <Button secondary onClick={() => {this.props.closeModal()}}>Cancel</Button>
              <Button solid onClick={ (e) => this.handleCreate(e) }>Move</Button>
            </ContentWrapper>
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

// function CodesList (props) {
//   let header = [{ content: 'Referral Code' }, { content: 'Description' }]
//   let rows = []
//   const onChange
//   props.referralCodes.forEach(function(code, index){
//     rows.push(
//       {"content": [{
//         "content": (<div key={index}><input onChange={(e) => {props.handleCodeSelect(e, code.id)}} type="checkbox"/>{code.referral_code}</div>), 
//         "content": {"content": code.referral_code}
//         }]    
//       )}
//     })
//   return (<div style={{maxHeight:'250px', overflowY:'scroll'}}><Table header={header} rows={rows}>Loading...</Table></div>)
//   }

function CampaignDropdown (props) {
  let campaigns = props.campaigns
  let dropdownOptions = props.campaigns.map(
    (campaign, index) => <option key={index} value={campaign.name}>{campaign.name}</option>
  )
  return (
    <select style={{width:'100%'}}>
    <option value="" disabled selected>Select a Campaign</option>
    {dropdownOptions}
    </select>
  )
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
    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest'},
    body: body
  }
  let response = await fetch(url, options)
  let data = await response.json()
  return data
}
