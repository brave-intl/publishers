import * as React from 'react'
import * as ReactDOM from 'react-dom'

import {
  StyledWrapper,
  StyledContainer,
  StyledText,
  StyledButton
} from './style'


export default class ReferralsNav extends React.Component {

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
        <StyledContainer>
            <StyledText header>Referrals</StyledText>
            <StyledButton>Create Code</StyledButton>
        </StyledContainer>
      </StyledWrapper>
    )
    }
}
