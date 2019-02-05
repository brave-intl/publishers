import * as React from 'react'

import {
  Wrapper,
  Container,
  ContentWrapper,
  TextArea,
  Button,
  Break,
  Input,
  Text
} from './ReferralsDeleteStyle'

import Select from 'brave-ui/components/formControls/select'

interface IReferralsModalProps {
  closeModal: any;
  codeToBeDeleted: any;
  refresh: any;
}

interface IReferralsModalState {
}

export default class ReferralsDelete extends React.Component<IReferralsModalProps, IReferralsModalState> {

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
            <Text heading>Delete Referral Code?</Text>
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
  let url = '/partners/referrals/delete_codes?id=' + code
  let options = {
    method: 'GET',
    headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' }
  }
  let response = await fetch(url, options)
  refresh()
  closeModal()
  return response
}
