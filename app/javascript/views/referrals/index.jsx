import React from 'react'
import ReactDOM from 'react-dom'

import {
  StyledWrapper,
  StyledGrid,
} from './style'

import ReferralsCard from './referralsCard/index.jsx'
import ReferralsHeader from './referralsHeader/index.jsx'

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
        <ReferralsHeader/>
        <StyledGrid>
          <ReferralsCard/>
          <ReferralsCard/>
          <ReferralsCard/>
          <ReferralsCard/>
        </StyledGrid>
      </StyledWrapper>
    )
    }
}
