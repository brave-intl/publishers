import * as React from "react";

import locale from "../../../../locale/en";

import {
  ErrorText,
  Header,
  Input,
  Label,
  PrimaryButton
} from "./EditCampaignDialogStyle";

interface IEditCampaignDialogProps {
  closeModal: () => void;
  afterSave: () => void;
  campaign: any;
}

interface IEditCampaignDialogState {
  name: any;
  errorText: string;
}

export default class EditCampaignDialog extends React.Component<
  IEditCampaignDialogProps,
  IEditCampaignDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      errorText: "",
      name: null
    };
  }

  public handleName = e => {
    this.setState({ name: e.target.value });
  };

  public isValidForm = () => {
    if (this.state.name) {
      return true;
    } else {
      return false;
    }
  };

  public async EditCampaign(name, campaignID, closeModal, afterSave) {
    const url = "/partners/referrals/promo_campaigns/" + campaignID;

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
      method: "PUT"
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
    return response;
  }

  public render() {
    return (
      <div>
        <Header>{locale.referrals.editCampaign}</Header>
        <br />
        <Label>{locale.campaign}</Label>
        <Input
          style={{ width: "100%" }}
          value={this.state.name}
          onChange={this.handleName}
          placeholder={locale.referrals.enterCampaign}
        />
        <br />
        <br />
        <br />
        {this.isValidForm() === true ? (
          <PrimaryButton
            onClick={() =>
              this.EditCampaign(
                this.state.name,
                this.props.campaign.promo_campaign_id,
                this.props.closeModal,
                this.props.afterSave
              )
            }
            enabled={true}
          >
            {locale.edit}
          </PrimaryButton>
        ) : (
          <PrimaryButton enabled={false}>{locale.edit}</PrimaryButton>
        )}
        <ErrorText>{this.state.errorText}</ErrorText>
      </div>
    );
  }
}
