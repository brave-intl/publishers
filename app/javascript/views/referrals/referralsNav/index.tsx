import * as React from 'react'

import {
  StyledWrapper,
  StyledContainer,
  StyledText,
  StyledButton
} from './style'

export default class ReferralsNav extends React.Component {

  render () {
    return (
      <StyledWrapper>
        <StyledContainer>
            <StyledText header>Referrals</StyledText>
            <StyledButton>Create Code</StyledButton>
        </StyledContainer>
      </StyledWrapper>
    )
  }
}
