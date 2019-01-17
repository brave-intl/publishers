import * as React from 'react'

import {
  Wrapper,
  Container,
  Grid
} from '../style'

import ReferralsNav from './referralsNav/index'
import ReferralsHeader from './referralsHeader/index'
import ReferralsCard from './referralsCard/index'

export default class Referrals extends React.Component {

  render () {
    return (
      <Wrapper>
        <ReferralsNav/>
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
