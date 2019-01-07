import * as React from 'react'

import {
  Wrapper,
  Container,
  Text,
  Button
} from './style.ts'

import locale from '../../../locale/en.js'

export default class ReferralsNav extends React.Component {

  render () {
    return (
      <Wrapper>
        <Container>
            <Text header>{locale.referrals}</Text>
            <Button>{locale.createCode}</Button>
        </Container>
      </Wrapper>
    )
  }
}
