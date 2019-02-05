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

  handleMove = async (e) => {
    moveCodes(this.state.selectedCodes, this.state.selectedCampaign)
    this.props.closeModal()
  }

  handleCampaignValue = (e) => {
    this.setState({ campaignValue: e.target.value })
  }

  handleCodeSelect = (e, id) => {
    let temp = this.state.selectedCodes
    if(e.target.checked) {
      temp.push(id)
      this.setState({selectedCodes: temp})
    }
    else {
      let index = temp.indexOf(id)
      if(index > -1){
        temp.splice(index, 1)
      }
      this.setState({selectedCodes: temp})
    }
  }

  handleCampaignSelect = (e) => {
    this.setState({selectedCampaign: e.target.value})
  }

  render () {

    return (
        <Container>
            <Text heading>Move Referral Codes</Text>
            <CodesList referralCodes={this.props.codesToBeMoved} handleCodeSelect={this.handleCodeSelect}/>
            <Break/>
            <CampaignDropdown campaigns={this.props.campaigns} handleCampaignSelect={this.handleCampaignSelect}/>
            <Break/>
            <ContentWrapper buttons>
              <Button secondary onClick={() => {this.props.closeModal()}}>Cancel</Button>
              <Button solid onClick={ (e) => this.handleMove(e) }>Move Selected</Button>
            </ContentWrapper>
        </Container>
    )
  }
}

function CodesList (props) {
  let header = [{ content: 'Referral Code' }, { content: 'Description' }]
  let rows = []
  props.referralCodes.forEach(function(code, index){
    let content = {
      "content": [
        {
          "content": (<div key={index}><input onChange={(e) => {props.handleCodeSelect(e, code.id)}} type="checkbox"/>{code.referral_code}</div>)
        }, 
        {
          "content": (<div key={index}>{code.referral_code}</div>)
        }
      ]
    }
    rows.push(content)
    })
  return (<div style={{maxHeight:'250px', overflowY:'scroll'}}><Table header={header} rows={rows}>Loading...</Table></div>)
  }

function CampaignDropdown (props) {
  let campaigns = props.campaigns
  let dropdownOptions = props.campaigns.map(
    (campaign, index) => <option key={index} value={campaign.promo_campaign_id}>{campaign.name}</option>
  )
  return (
    <select onChange={(e) => {props.handleCampaignSelect(e)}} style={{width:'100%'}}>
      <option value="" disabled selected>Select a Campaign</option>
      {dropdownOptions}
    </select>
  )
}

async function moveCodes (selectedCodes, selectedCampaign) {
  let url = '/partners/referrals/move_codes'
  let body = new FormData()
  body.append('codes', JSON.stringify(selectedCodes))
  body.append('campaign', selectedCampaign)
  let options = {
    method: 'POST',
    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").getAttribute("content") },
    body: body
  }
  let response = await fetch(url, options)
  return
}
