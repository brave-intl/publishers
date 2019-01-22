import * as React from 'react'

import {
  Wrapper,
  Container,
  TextWrapper,
  ContentWrapper,
  TextArea,
  Button,
  Break,
  Input,
  Text
} from './style.ts'

import locale from '../../../locale/en.js'

export default class ReferralsModal extends React.Component {

   handleCreate = (e) => {
//
  }

  handleCancel = (e) => {
//
 }


  render () {
    return (
      <Wrapper open={this.props.modalOpen}>
        <Container>
            <Text heading>Create Referral Code</Text>
            <Break/>
            <Text subtext>Number of referral codes needed</Text>
            <ContentWrapper codes>
              <Button circle>-</Button>
              <Input codes/>
              <Button circle>+</Button>
            </ContentWrapper>
            <ContentWrapper>
            <Text description>Maximum number of referral codes for this account:&nbsp;</Text>
            <Text description>{this.props.maxCodes}</Text>
            </ContentWrapper>
            <Break/>
            <Text subtext>Campaign name for these referrals (optional)</Text>
            <Input name/>
            <Break/>
            <Text subtext>Set campaign color</Text>
            <Break/>
            <Text subtext>Description (Optional)</Text>
            <TextArea/>
            <Break/>
            <ContentWrapper buttons>
              <Button secondary onClick={ (e) => this.handleCancel(e) }>Cancel</Button>
              <Button solid onClick={ (e) => this.handleCreate(e) }>Create</Button>
            </ContentWrapper>
        </Container>
      </Wrapper>
    )
  }
}
