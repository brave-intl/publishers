import * as React from "react";

import locale from "../../../../locale/en";

import { Header, Label, Input, PrimaryButton } from "./CreateDialogStyle";

interface ICreateDialogProps {
  closeModal: () => void;
  afterSave: () => void;
}

interface ICreateDialogState {
  campaign: any;
  numberOfCodes: any;
}

export default class CreateDialog extends React.Component<
  ICreateDialogProps,
  ICreateDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      numberOfCodes: 1,
      campaign: null
    };
  }

  handleCampaignValue = e => {
    this.setState({ campaign: e.target.value });
  };

  handleCreate = async e => {
    let newCampaign = null;

    if (this.state.campaign) {
      newCampaign = await createCampaign(this.state.campaign);
      createReferralCode(1, newCampaign.id);
    } else {
      createReferralCode(1, null);
    }
    this.props.afterSave();
    this.props.closeModal();
  };

  public render() {
    return (
      <div>
        <Header>Create referral code?</Header>
        <br />
        <Label>Campaign Name </Label>
        <Input
          value={this.state.campaign}
          onChange={this.handleCampaignValue}
        />
        <br />
        <br />
        {/* <Label>Description </Label>
        <Input
          value={this.state.campaign}
          onChange={this.handleCampaignValue}
        />
        <br /> */}
        <br />
        <PrimaryButton enabled={true} onClick={this.handleCreate}>
          Create
        </PrimaryButton>
      </div>
    );
  }
}

async function createCampaign(name) {
  let url = "/partners/referrals/create_campaign";
  let body = new FormData();
  body.append("name", name);
  let options = {
    method: "POST",
    headers: {
      Accept: "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRF-Token": document.head
        .querySelector("[name=csrf-token]")
        .getAttribute("content")
    },
    body: body
  };
  let response = await fetch(url, options);
  let data = await response.json();
  return data;
}

async function createReferralCode(numberOfCodes, campaignID) {
  let url = "/partners/referrals/create_codes";
  let body = new FormData();
  body.append("number", numberOfCodes);
  body.append("promo_campaign_id", campaignID);
  let options = {
    method: "POST",
    headers: {
      Accept: "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRF-Token": document.head
        .querySelector("[name=csrf-token]")
        .getAttribute("content")
    },
    body: body
  };
  let response = await fetch(url, options);
  let data = await response.json();
  return data;
}
