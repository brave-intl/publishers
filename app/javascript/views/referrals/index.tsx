import * as React from 'react'

import {
  StyledWrapper,
  StyledContainer,
  StyledGrid
} from './style.ts'

import ReferralsNav from './referralsNav/index.tsx'
import ReferralsHeader from './referralsHeader/index.tsx'
import ReferralsCard from './referralsCard/index.tsx'

export default class Referrals extends React.Component {

  render () {
    return (
      <StyledWrapper>
        <ReferralsNav/>
        <StyledContainer>
          <ReferralsHeader/>
          <StyledGrid>
            <ReferralsCard/>
            <ReferralsCard/>
            <ReferralsCard/>
            <ReferralsCard/>
          </StyledGrid>
        </StyledContainer>
      </StyledWrapper>
    )
  }
}
