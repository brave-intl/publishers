import * as React from 'react'

import {
  Wrapper,
  Container,
  Grid
} from './style.ts'

import ReferralsNav from './referralsNav/index.tsx'
import ReferralsModal from './referralsModal/index.tsx'
import ReferralsHeader from './referralsHeader/index.tsx'
import ReferralsCard from './referralsCard/index.tsx'
import ReferralsInfo from './referralsInfo/index.tsx'

export default class Referrals extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      mode: 'grid',
      index: null,
      campaigns: [],
      modalOpen: false
    }
    this.openModal = this.openModal.bind(this)
    // this.changeMode = this.changeMode.bind(this)
  }

  componentDidMount () {
    // this.fetchReferralsData()
  }

  async fetchReferralsData () {
    let url = '/publishers/referrals/campaigns'

    let options = {
      method: 'GET',
      credentials: 'same-origin',
      headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector('[name=csrf-token]').content }
    }

    let response = await fetch(url, options)
    let data = await response.json()
    this.setState({ campaigns: data })
  }

  openModal () {
    this.setState({
      modalOpen: true
    })
  }

  changeMode = (mode, index) => {
    this.setState({
      mode: mode,
      index: index
    })
  }

  render () {
    return (
      <Wrapper>
        <ReferralsNav openModal={this.openModal}/>
        <ReferralsModal modalOpen={this.state.modalOpen} maxCodes={400}/>
        {/* <ReferralsContent mode={this.state.mode} campaigns={this.state.campaigns} changeMode={this.changeMode} index={this.state.index}/> */}
      </Wrapper>
    )
  }
}

function ReferralsContent (props) {
  switch (props.mode) {
    case 'single':
      return (
        <Container>
          <ReferralsInfo campaign={props.campaigns[props.index]} changeMode={props.changeMode}/>
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
    (campaign, index) => <ReferralsCard key={index} campaign={campaign.name} changeMode={props.changeMode} index={index}/>
  )
  return <Grid>{referralsCardMap}</Grid>
}
