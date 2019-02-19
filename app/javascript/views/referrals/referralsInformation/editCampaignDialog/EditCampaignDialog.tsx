import * as React from "react";

import locale from "../../../../locale/en";

import { Header, Input, Label, PrimaryButton } from "./EditCampaignDialogStyle";

const initialState = { isLoading: false, errorText: "" };

interface IEditCampaignDialogProps {
  closeModal: () => void;
  afterSave: () => void;
  campaign: any;
}

interface IEditCampaignDialogState {
  name: any;
}

export default class EditCampaignDialog extends React.Component<
  IEditCampaignDialogProps,
  IEditCampaignDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
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

  public render() {
    return (
      <div>
        <Header>{locale.referrals.editCampaign}</Header>
        <br />
        <Label>{locale.referrals.enterCampaign}</Label>
        <Input
          style={{ width: "100%" }}
          value={this.state.name}
          onChange={this.handleName}
          placeholder={"Name this campaign"}
        />
        <br />
        <br />
        <br />
        {this.isValidForm() === true ? (
          <PrimaryButton
            onClick={() =>
              EditCampaign(
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
      </div>
    );
  }
}

async function EditCampaign(name, campaignID, closeModal, afterSave) {
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
  afterSave();
  closeModal();
  return response;
}
