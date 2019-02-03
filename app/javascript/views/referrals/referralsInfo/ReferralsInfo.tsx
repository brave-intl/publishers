import * as React from 'react'

import {
  Wrapper,
  Container,
  Row,
  Content,
  Button,
  Text
} from './ReferralsInfoStyle'

import { CheckCircleIcon, CaratLeftIcon } from 'brave-ui/components/icons'

interface IReferralsInfoProps {
  openModal: any;
  campaign: any;
  changeMode: any;
  openAddModal: any;
  openDeleteModal: any;
  openMoveModal: any;
}

interface IReferralsInfoState {
  date: any;
}

export default class ReferralsInfo extends React.Component<IReferralsInfoProps, IReferralsInfoState> {

  constructor (props) {
    super(props)
    this.state = {
      date: ''
    }
  }

  componentDidMount () {
    var options = { year: 'numeric', month: 'long', day: 'numeric' }
    let date = new Date(this.props.campaign.created_at)
    let formattedDate = date.toLocaleDateString("en-US", options)
    this.setState({date: formattedDate})
  }

  render () {
    return (
        <Container>
          <Row campaign>
            <Content back onClick={() => { this.props.changeMode('grid', null) }}><CaratLeftIcon/></Content>
            <Content campaignIcon><CheckCircleIcon/></Content>
            <Content>
              <Text header>Campaign</Text>
              <Text h2>{this.props.campaign.name}</Text>
            </Content>
            <Content>
              <Text header>Downloads</Text>
              <Text h2>{processDownloads(this.props.campaign.promo_registrations)}</Text>
            </Content>
            <Content>
              <Text header>Installs</Text>
              <Text h2>{processInstalls(this.props.campaign.promo_registrations)}</Text>
            </Content>
            <Content>
              <Text header>30-Day-Use</Text>
              <Text h2>{processThirtyDayUse(this.props.campaign.promo_registrations)}</Text>
            </Content>
            <Content>
              <Text header>Estimated Earnings</Text>
              <Text h2>tbd</Text>
            </Content>
          </Row>
          <Row lineBreak />
          <Row>
            <Content created>
              <Text h4>Created</Text>
              <Text style={{ paddingLeft: '8px' }} p>{this.state.date}</Text>
            </Content>
          </Row>
          <Row>
            <Content total>
              <Text h4>Total Referral Codes</Text>
              <Text style={{ paddingLeft: '8px' }} p>{this.props.campaign.promo_registrations.length}</Text>
            </Content>
          </Row>
          <Row buttons>
            <Content buttons>
              <Button onClick={() => {this.props.openAddModal(this.props.campaign.promo_campaign_id)}}>Add Codes</Button>
              <Button onClick={() => {this.props.openMoveModal(this.props.campaign.promo_registrations)}} style={{marginLeft: '8px'}}>Move Codes</Button>
            </Content>
          </Row>
          <Row tableHead>
            <Content tableHeader>
              <Text header>REFERRAL CODE</Text>
            </Content>
            <Content tableHeader>
              <Text header>DESCRIPTION</Text>
            </Content>
            <Content tableHeader>
              <Text header>DOWNLOADS</Text>
            </Content>
            <Content tableHeader>
              <Text header>INSTALLS</Text>
            </Content>
            <Content tableHeader>
              <Text header>30-DAY-USE</Text>
            </Content>
            <Content tableHeader>
              <Text header>ACTIONS</Text>
            </Content>
          </Row>
          <TableRows campaign={this.props.campaign} openDeleteModal={this.props.openDeleteModal}/>
        </Container>
    )
  }
}

function TableRows (props) {
  const referralCodes = props.campaign.promo_registrations.map(
    (referralCode, index) => (
    <Row tableRow key={index} style={{ display: 'flex', justifyContent: 'space-between' }}>
      <Content tableHeader>
        <Text>{referralCode.referral_code}</Text>
      </Content>
      <Content tableHeader>
        <Text>A description</Text>
      </Content>
      <Content tableHeader>
        <Text>{JSON.parse(referralCode.stats)[0].retrievals}</Text>
      </Content>
      <Content tableHeader>
        <Text>{JSON.parse(referralCode.stats)[0].first_runs}</Text>
      </Content>
      <Content tableHeader>
        <Text>{JSON.parse(referralCode.stats)[0].finalized}</Text>
      </Content>
      <Content tableHeader>
        <Text style={{cursor: 'pointer', userSelect: 'none'}} onClick={() => {props.openDeleteModal(referralCode.id)}}>Delete</Text>
      </Content>
    </Row>
  )
  )
  return <div>{referralCodes}</div>
}

function processDownloads (referralCodes) {
  let downloads = 0
  referralCodes.forEach(function (code) {
    downloads += JSON.parse(code.stats)[0].retrievals
  })
  return downloads
}

function processInstalls (referralCodes) {
  let installs = 0
  referralCodes.forEach(function (code) {
    installs += JSON.parse(code.stats)[0].first_runs
  })
  return installs
}

function processThirtyDayUse (referralCodes) {
  let thirtyDayUse = 0
  referralCodes.forEach(function (code) {
    thirtyDayUse += JSON.parse(code.stats)[0].finalized
  })
  return thirtyDayUse
}
