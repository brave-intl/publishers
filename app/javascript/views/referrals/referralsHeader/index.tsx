import * as React from 'react'

import {
  Wrapper,
  ContentWrapper,
  TextWrapper,
  Text,
  Box
} from './style'

import locale from '../../../locale/en'

export default class ReferralsHeader extends React.Component {

  render () {
    return (
      <Wrapper>
        <ContentWrapper>
          <TextWrapper>
            <Text header>{locale.campaigns}</Text>
            <Text stat>9</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.referralCodes}</Text>
            <Text stat blue>18</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.downloads}</Text>
            <Text stat>18</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.installs}</Text>
            <Text stat>18</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>{locale.thirtyDay}</Text>
            <Text stat purple>18</Text>
          </TextWrapper>
          <TextWrapper>
            <Text header>Estimated Earnings</Text>
            <TextWrapper earnings>
              <Text stat purple>999</Text>
              <Text bat purple>{locale.bat}</Text>
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
