import * as React from 'react'

import {
  Wrapper,
  Grid,
  Row,
  IconWrapper,
  TextWrapper,
  ContentWrapper,
  Text
} from './style'

import { CheckCircleIcon, CaratRightIcon } from 'brave-ui/components/icons'

import locale from '../../../locale/en.js'

export default class ReferralsCard extends React.Component {

  render () {
    return (
      <Wrapper>
        <Grid>

        <Row title>
          <IconWrapper check>
            <CheckCircleIcon/>
          </IconWrapper>
          <ContentWrapper>
            <TextWrapper>
              <Text title>{this.props.campaign}</Text>
            </TextWrapper>
            <TextWrapper created>
              <Text created>{locale.created}</Text>
              <Text date>Jan 20, 2018</Text>
            </TextWrapper>
          </ContentWrapper>
        </Row>

        <Row stats>
          <TextWrapper stats>
            <Text header>{locale.downloads}</Text>
            <Text stat>99999</Text>
          </TextWrapper>
          <TextWrapper stats>
            <Text header>{locale.installs}</Text>
            <Text stat>99999</Text>
          </TextWrapper>
          <TextWrapper stats>
            <Text header>{locale.thirtyDay}</Text>
            <Text use>99999</Text>
          </TextWrapper>
        </Row>

        <Row total>
          <TextWrapper total>
            <Text total>{locale.totalNumber}</Text>
          </TextWrapper>
          <TextWrapper total>
            <Text codes>999</Text>
          </TextWrapper>
          <IconWrapper carat>
            <CaratRightIcon onClick={() => { this.props.changeMode('single', this.props.index) }}/>
          </IconWrapper>
        </Row>

        </Grid>
      </Wrapper>
    )
  }
}
