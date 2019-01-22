import * as React from 'react'

import {
  Wrapper,
  Container,
  Row,
  Content,
  Button,
  Text
} from './style.ts'

import { CheckCircleIcon, CaratLeftIcon } from 'brave-ui/components/icons'

export default class ReferralsInfo extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
    }
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
              <Text h2>9999</Text>
            </Content>
            <Content>
              <Text header>Installs</Text>
              <Text h2>9999</Text>
            </Content>
            <Content>
              <Text header>30-Day-Use</Text>
              <Text h2>9999</Text>
            </Content>
            <Content>
              <Text header>Estimated Earnings</Text>
              <Text h2>9999</Text>
            </Content>
          </Row>
          <Row lineBreak />
          <Row>
            <Content created>
              <Text h4>Created</Text>
              <Text style={{ paddingLeft: '8px' }} p>9999</Text>
            </Content>
          </Row>
          <Row>
            <Content total>
              <Text h4>Total Referral Codes</Text>
              <Text style={{ paddingLeft: '8px' }} p>9999</Text>
            </Content>
          </Row>
          <Row buttons>
            <Content buttons>
              <Button>Add More Codes</Button>
              <Button style={{marginLeft: '8px'}}>Move Codes</Button>
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
          <TableRows campaign={this.props.campaign} />
        </Container>
    )
  }
}

function TableRows (props) {
  console.log(props.campaign)
  const referralCodes = props.campaign.referral_codes.map(
    (referralCode, index) => (
    <Row tableRow key={index} style={{ display: 'flex', justifyContent: 'space-between' }}>
      <Content tableHeader>
        <Text>{referralCode.referral_code}</Text>
      </Content>
      <Content tableHeader>
        <Text>A description</Text>
      </Content>
      <Content tableHeader>
        <Text>{JSON.parse(referralCode.stats)[0].first_runs}</Text>
      </Content>
      <Content tableHeader>
        <Text>{JSON.parse(referralCode.stats)[0].retrievals}</Text>
      </Content>
      <Content tableHeader>
        <Text>{JSON.parse(referralCode.stats)[0].finalized}</Text>
      </Content>
      <Content tableHeader>
        <Text>Delete</Text>
      </Content>
    </Row>
  )
  )
  return <div>{referralCodes}</div>
}
