import * as React from "react";

import locale from "../../../../../locale/en";

import {
  ErrorText,
  Header,
  Input,
  Label,
  PrimaryButton
} from "./CreateDialogStyle";

interface ICreateDialogProps {
  closeModal: () => void;
  afterSave: () => void;
}

interface ICreateDialogState {
  campaignName: string;
  errorText: string;
  number: number;
  description: string;
}

export default class CreateDialog extends React.Component<
  ICreateDialogProps,
  ICreateDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      campaignName: null,
      description: null,
      errorText: "",
      number: 1
    };
  }

  public handleCampaignValue = e => {
    this.setState({ campaignName: e.target.value });
  };

  public handleNumber = e => {
    this.setState({ number: e.target.value });
  };

  public handleDescription = e => {
    this.setState({ description: e.target.value });
  };

  public handleCreate = async e => {
    const newCampaign = await createCampaign(this.state.campaignName);
    this.createReferralCode(
      this.state.number,
      this.state.description,
      newCampaign.id,
      this.props.afterSave,
      this.props.closeModal
    );
  };

  public isValidForm = () => {
    return (
      this.state.campaignName &&
      (this.state.number > 0 && this.state.number < 100)
    );
  };

  public async createReferralCode(
    numberOfCodes,
    description,
    campaignID,
    afterSave,
    closeModal
  ) {
    const url = "/partners/referrals/promo_registrations";
    const body = new FormData();
    body.append("number", numberOfCodes);
    body.append("description", description);
    body.append("promo_campaign_id", campaignID);
    const options = {
      body,
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "POST"
    };
    const response = await fetch(url, options);
    if (response.status >= 400) {
      this.setState({
        errorText: "An unexpected error has occurred. Please try again later."
      });
      return;
    }
    afterSave();
    closeModal();
  }

  public render() {
    return (
      <div>
        <Header>{locale.referrals.createCampaign}</Header>
        <br />
        <br />
        <Label>{locale.referrals.numberOfCodes}</Label>
        <br />
        <Input
          style={{ width: "25%" }}
          value={this.state.number}
          onChange={this.handleNumber}
          type="number"
        />
        <br />
        <br />
        <Label>{locale.campaign}</Label>
        <Input
          style={{ width: "100%" }}
          value={this.state.campaignName}
          onChange={this.handleCampaignValue}
          placeholder={locale.referrals.campaignPlaceholder}
        />
        <br />
        <br />
        <Label>{locale.referrals.enterDescription}</Label>
        <Input
          style={{ width: "100%" }}
          value={this.state.description}
          onChange={this.handleDescription}
          placeholder={locale.referrals.referralCodePlaceholder}
        />
        <br />
        <br />
        <br />
        {this.isValidForm() === true ? (
          <PrimaryButton enabled={true} onClick={this.handleCreate}>
            {locale.create}
          </PrimaryButton>
        ) : (
          <PrimaryButton enabled={false}>{locale.create}</PrimaryButton>
        )}
        <ErrorText>{this.state.errorText}</ErrorText>
      </div>
    );
  }
}

async function createCampaign(name) {
  const url = "/partners/referrals/promo_campaigns/";
  const body = new FormData();
  body.append("name", name);
  const options = {
    body,
    headers: {
      Accept: "application/json",
      "X-CSRF-Token": document.head
        .querySelector("[name=csrf-token]")
        .getAttribute("content"),
      "X-Requested-With": "XMLHttpRequest"
    },
    method: "POST"
  };
  const response = await fetch(url, options);
  const data = await response.json();
  return data;
}
