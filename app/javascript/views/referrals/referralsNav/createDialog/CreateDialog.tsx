import * as React from "react";

import locale from "../../../../locale/en";

import { Header, Label, Input, PrimaryButton } from "./CreateDialogStyle";

interface ICreateDialogProps {
  closeModal: () => void;
  afterSave: () => void;
}

interface ICreateDialogState {
  campaign: any;
  number: any;
  description: any;
}

export default class CreateDialog extends React.Component<
  ICreateDialogProps,
  ICreateDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      number: 1,
      description: null,
      campaign: null
    };
  }

  handleCampaignValue = e => {
    this.setState({ campaign: e.target.value });
  };

  handleNumber = e => {
    this.setState({ number: e.target.value });
  };

  handleDescription = e => {
    this.setState({ description: e.target.value });
  };

  handleCreate = async e => {
    let newCampaign = null;

    if (this.state.campaign) {
      newCampaign = await createCampaign(this.state.campaign);
      createReferralCode(
        this.state.number,
        this.state.description,
        newCampaign.id,
        this.props.afterSave,
        this.props.closeModal
      );
    } else {
      createReferralCode(
        this.state.number,
        this.state.description,
        null,
        this.props.afterSave,
        this.props.closeModal
      );
    }
  };

  public render() {
    return (
      <div>
        <Header>Create referral code?</Header>
        <br />
        <br />
        <Label>Number of Codes</Label>
        <Input value={this.state.number} onChange={this.handleNumber} />
        <br />
        <br />
        <Label>Description</Label>
        <Input
          value={this.state.description}
          onChange={this.handleDescription}
        />
        <br />
        <br />
        <Label>Campaign</Label>
        <Input
          value={this.state.campaign}
          onChange={this.handleCampaignValue}
        />
        <br />
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

async function createReferralCode(
  numberOfCodes,
  description,
  campaignID,
  afterSave,
  closeModal
) {
  let url = "/partners/referrals/create_codes";
  let body = new FormData();
  body.append("number", numberOfCodes);
  body.append("description", description);
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
  afterSave();
  closeModal();
}
