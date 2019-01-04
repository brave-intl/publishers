import * as React from 'react'

import {
  Wrapper,
  Grid,
  TitleWrapper,
  StatsWrapper,
  TotalWrapper,
  IconWrapper,
  TextWrapper,
  ContentWrapper,
  Text
} from './style'

import { CheckCircleIcon, CaratRightIcon } from 'brave-ui/components/icons'

export default class ReferralsCard extends React.Component {

  render () {
    return (
      <Wrapper>
        <Grid>

        <TitleWrapper>
          <IconWrapper check>
            <CheckCircleIcon/>
          </IconWrapper>
          <ContentWrapper>
            <TextWrapper>
              <Text title>Campaign Name</Text>
            </TextWrapper>
            <TextWrapper created>
              <Text created>Created</Text>
              <Text date>Jan 20, 2018</Text>
            </TextWrapper>
          </ContentWrapper>
        </TitleWrapper>

        <StatsWrapper>
          <TextWrapper stats>
            <Text header>DOWNLOADS</Text>
            <Text stat>99999</Text>
          </TextWrapper>
          <TextWrapper stats>
            <Text header>INSTALLS</Text>
            <Text stat>99999</Text>
          </TextWrapper>
          <TextWrapper stats>
            <Text header>30-DAY USE</Text>
            <Text use>99999</Text>
          </TextWrapper>
        </StatsWrapper>

        <TotalWrapper>
          <TextWrapper total>
            <Text total>Total Number of Codes</Text>
          </TextWrapper>
          <TextWrapper total>
            <Text codes>999</Text>
          </TextWrapper>
          <IconWrapper carat>
            <CaratRightIcon/>
          </IconWrapper>
        </TotalWrapper>

        </Grid>
      </Wrapper>
    )
  }
}
