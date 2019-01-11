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

export default class Referrals extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
      modalOpen: false
    }
    this.openModal = this.openModal.bind(this)
  }

  openModal () {
    this.setState({
      modalOpen: true
    })
  }

  render () {
    return (
      <Wrapper>
        <ReferralsNav openModal={this.openModal}/>
        {this.state.modalOpen ? <ReferralsModal maxCodes={400}/> : null}
        <Container>
          <ReferralsHeader/>
          <Grid>
            <ReferralsCard/>
            <ReferralsCard/>
            <ReferralsCard/>
            <ReferralsCard/>
          </Grid>
        </Container>
      </Wrapper>
    )
  }
}
