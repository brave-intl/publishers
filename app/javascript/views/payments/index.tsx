import * as React from 'react'

import {
  Wrapper,
  Container,
  Grid
} from '../style'
import UpholdCard from './upholdCard';

export default class Referrals extends React.Component {

  render () {
    return (
      <Wrapper>
        <Container>
          <Grid>
            <UpholdCard name="dofus" />
          </Grid>
        </Container>
      </Wrapper>
    )
  }
}
