import * as React from 'react'

import {
  Wrapper
} from './ReferralsModalStyle.ts'

import ReferralsCreate from './referralsCreate/ReferralsCreate.tsx'
import ReferralsAdd from './referralsAdd/ReferralsAdd.tsx'
import ReferralsMove from './referralsMove/ReferralsMove.tsx'
import ReferralsDelete from './referralsDelete/ReferralsDelete.tsx'

import locale from '../../../locale/en.js'

export default class ReferralsModal extends React.Component {

  constructor (props) {
    super(props)
    this.state = {
    }
  }

  render () {
    return (
      <Wrapper open={this.props.modalOpen}>
        <ReferralsModalType
          modalType={this.props.modalType}
          openModal={this.props.openModal}
          closeModal={this.props.closeModal}
          campaignToAddCodesTo={this.props.campaignToAddCodesTo}
          codeToBeDeleted={this.props.codeToBeDeleted}
          codesToBeMoved={this.props.codesToBeMoved}
          campaigns={this.props.campaigns}
          refresh={this.props.refresh}
        />
      </Wrapper>
    )
  }
}

function ReferralsModalType (props) {
  switch (props.modalType) {
    case 'Create':
      return <ReferralsCreate closeModal={props.closeModal}/>
      break
    case 'Add':
      return <ReferralsAdd closeModal={props.closeModal} campaignToAddCodesTo={props.campaignToAddCodesTo} refresh={props.refresh}/>
      break
    case 'Move':
      return <ReferralsMove closeModal={props.closeModal} codesToBeMoved={props.codesToBeMoved} campaigns={props.campaigns}/>
      break
    case 'Delete':
      return <ReferralsDelete closeModal={props.closeModal} codeToBeDeleted={props.codeToBeDeleted} refresh={props.refresh}/>
      break
  }
}
