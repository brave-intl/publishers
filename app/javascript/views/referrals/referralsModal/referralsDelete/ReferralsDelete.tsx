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
} from './ReferralsDeleteStyle.ts'

import Select from 'brave-ui/components/formControls/select'

import locale from '../../../locale/en.js'

export default class ReferralsDelete extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
    }
  }

  handleDelete = async (e) => {
    deleteReferralCode(this.props.codeToBeDeleted, this.props.refresh, this.props.closeModal)
  }

  render () {
    return (
        <Container>
            <Text heading>Delete Referral Code? {this.props.codeToBeDeleted}</Text>
            <Break/>
            <ContentWrapper buttons>
              <Button secondary onClick={ () => {this.props.closeModal()} }>Cancel</Button>
              <Button solid onClick={ (e) => this.handleDelete(e) }>Delete</Button>
            </ContentWrapper>
        </Container>
    )
  }
}

async function deleteReferralCode (code, refresh, closeModal) {
  let url = '/publishers/' + 'c1a84225-471a-4f82-8691-ab62eac7ab46' + '/referrals/delete_codes?id=' + code
  let options = {
    method: 'GET',
    credentials: 'same-origin',
    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector('[name=csrf-token]').content }
  }
  let response = await fetch(url, options)
  refresh()
  closeModal()
  return response
}
