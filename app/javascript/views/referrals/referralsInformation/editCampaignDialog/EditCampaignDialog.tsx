import * as React from "react";

import locale from "../../../../locale/en";

import { Header, PrimaryButton, Label, Input } from "./EditCampaignDialogStyle";

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

  handleName = e => {
    this.setState({ name: e.target.value });
  };

  isValidForm = () => {
    if (this.state.name) {
      return true;
    } else {
      return false;
    }
  };

  public render() {
    return (
      <div>
        <Header>Change Campaign name?</Header>
        <br />
        <Label>Enter new name</Label>
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
            Change
          </PrimaryButton>
        ) : (
          <PrimaryButton enabled={false}>Change</PrimaryButton>
        )}
      </div>
    );
  }
}

async function EditCampaign(name, campaignID, closeModal, afterSave) {
  let url = "/partners/referrals/promo_campaigns/" + campaignID;

  let body = new FormData();
  body.append("name", name);
  let options = {
    method: "PUT",
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
  return response;
}
