import * as React from 'react'
import * as ReactDOM from 'react-dom'

import {
  StyledWrapper,
  StyledContainer,
  StyledGrid,
} from './style'

import ReferralsNav from './referralsNav/index.tsx'
import ReferralsHeader from './referralsHeader/index.tsx'
import ReferralsCard from './referralsCard/index.tsx'


export default class Referrals extends React.Component {

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
