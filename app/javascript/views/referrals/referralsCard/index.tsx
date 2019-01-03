import * as React from 'react'
import * as ReactDOM from 'react-dom'

import {
  StyledWrapper,
  StyledGrid,
  StyledTitleWrapper,
  StyledStatsWrapper,
  StyledTotalWrapper,
  StyledIconWrapper,
  StyledTextWrapper,
  StyledContentWrapper,
  StyledImage,
  StyledText,
} from './style'

import { CheckCircleIcon, CaratRightIcon } from 'brave-ui/components/icons'

export default class ReferralsCard extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
    }
  }

  componentWillMount(){
  }

  componentDidMount(){
  }



  render() {
    return (
      <StyledWrapper>
        <StyledGrid>

        <StyledTitleWrapper>
          <StyledIconWrapper check>
            <CheckCircleIcon/>
          </StyledIconWrapper>
          <StyledContentWrapper>
            <StyledTextWrapper>
              <StyledText title>Campaign Name</StyledText>
            </StyledTextWrapper>
            <StyledTextWrapper created>
              <StyledText created>Created</StyledText>
              <StyledText date>Jan 20, 2018</StyledText>
            </StyledTextWrapper>
          </StyledContentWrapper>
        </StyledTitleWrapper>

        <StyledStatsWrapper>
          <StyledTextWrapper stats>
            <StyledText header>DOWNLOADS</StyledText>
            <StyledText stat>99999</StyledText>
          </StyledTextWrapper>
          <StyledTextWrapper stats>
            <StyledText header>INSTALLS</StyledText>
            <StyledText stat>99999</StyledText>
          </StyledTextWrapper>
          <StyledTextWrapper stats>
            <StyledText header>30-DAY USE</StyledText>
            <StyledText use>99999</StyledText>
          </StyledTextWrapper>
        </StyledStatsWrapper>

        <StyledTotalWrapper>
          <StyledTextWrapper total>
            <StyledText total>Total Number of Codes</StyledText>
          </StyledTextWrapper>
          <StyledTextWrapper total>
            <StyledText codes>999</StyledText>
          </StyledTextWrapper>
          <StyledIconWrapper carat>
            <CaratRightIcon/>
          </StyledIconWrapper>
        </StyledTotalWrapper>

        </StyledGrid>
      </StyledWrapper>
    )
    }
}
