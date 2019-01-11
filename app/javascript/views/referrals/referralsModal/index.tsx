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
    let url = '/admin/unattached_promo_registrations?number_of_codes_to_create=5'

    let options = {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Accept': 'text/html', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector('[name=csrf-token]').content }
    }
    // let response = await fetch(url, options)
    // let parsed = await response.json()

    fetch(url, options)
      .then(function(response) {
        console.log(response)
        return response.json();
      })
      .then(function(myJson) {
        console.log(JSON.stringify(myJson));
      });
  }

  handleCancel = (e) => {
   let url = '/admin/unattached_promo_registrations'

   let options = {
     method: 'GET',
     credentials: 'same-origin',
     headers: { 'Accept': 'application/json', 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector('[name=csrf-token]').content }
   }
   // let response = await fetch(url, options)
   // let parsed = await response.json()

   fetch(url, options)
     .then(function(response) {
       console.log(response)
       return response.json();
     })
     .then(function(myJson) {
       console.log(JSON.stringify(myJson));
     });
 }


  render () {
    return (
      <Wrapper>
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
