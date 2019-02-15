import * as React from "react";

import locale from "../../../../locale/en";

import { Header, Input, Label, PrimaryButton } from "./EditDialogStyle";

const initialState = { isLoading: false, errorText: "" };

interface IEditDialogProps {
  closeModal: () => void;
  afterSave: () => void;
  campaign: any;
}

interface IEditDialogState {
  campaignName: any;
}

export default class EditDialog extends React.Component<
  IEditDialogProps,
  IEditDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      campaignName: null
    };
  }

  public handlecampaignName = e => {
    this.setState({ campaignName: e.target.value });
  };

  public render() {
    return (
      <div>
        <Header>Edit Campaign?</Header>
        <br />
        <Label>Enter new campaign name</Label>
        <Input
          value={this.state.campaignName}
          onChange={this.handlecampaignName}
        />
        <br />
        <br />
        <PrimaryButton
          onClick={() =>
            EditCode(
              this.state.campaignName,
              this.props.campaign.promo_campaign_id,
              this.props.closeModal,
              this.props.afterSave
            )
          }
          enabled={true}
        >
          Edit
        </PrimaryButton>
      </div>
    );
  }
}

async function EditCode(campaignName, campaignID, closeModal, afterSave) {
  const url = "/partners/referrals/update_campaign";

  const body = new FormData();
  body.append("campaignName", campaignName);
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
  afterSave();
  closeModal();
  return response;
}
