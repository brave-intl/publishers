import * as React from 'react'

import {
  Wrapper,
  ContentWrapper,
  TextWrapper,
  Text,
  Box
} from './style.ts'

export default class ReferralsHeader extends React.Component {

  render () {
    return (
      <Wrapper>
        <ContentWrapper>
          <TextWrapper>
            <Text header>CAMPAIGNS</Text>
            <Text stat>9</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>REFERRAL CODES</Text>
            <Text stat blue>499</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>DOWNLOADS</Text>
            <Text stat>9999</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>INSTALLS</Text>
            <Text stat>999</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>30-DAY USE</Text>
            <Text stat purple>999</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>ESTIMATED EARNINGS</Text>
            <TextWrapper earnings>
              <Text stat purple>999</Text>
              <Text bat purple>BAT</Text>
            </TextWrapper>
          </TextWrapper>
        </ContentWrapper>
        <ContentWrapper box>
        <Box>
        <Text box>January 2019</Text>
        </Box>
        </ContentWrapper>
      </Wrapper>
    )
  }
}
