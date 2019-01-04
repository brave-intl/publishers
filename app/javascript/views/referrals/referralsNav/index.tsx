import * as React from 'react'

import {
  Wrapper,
  Container,
  Text,
  Button
} from './style.ts'

export default class ReferralsNav extends React.Component {

  render () {
    return (
      <Wrapper>
        <Container>
            <Text header>Referrals</Text>
            <Button>Create Code</Button>
        </Container>
      </Wrapper>
    )
  }
}
