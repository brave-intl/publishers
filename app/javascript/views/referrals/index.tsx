import * as React from 'react'

import {
  Wrapper,
  Container,
  Grid
} from './style.ts'

import ReferralsNav from './referralsNav/index.tsx'
import ReferralsHeader from './referralsHeader/index.tsx'
import ReferralsCard from './referralsCard/index.tsx'

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
