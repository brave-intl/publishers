import * as React from "react";

import locale from "../../../../locale/en";

import { Header, PrimaryButton, Label, Input } from "./AddDialogStyle";

const initialState = { isLoading: false, errorText: "" };

interface IAddDialogProps {
  closeModal: () => void;
  afterSave: () => void;
  campaign: any;
}

interface IAddDialogState {
  description: any;
  number: any;
}

export default class AddDialog extends React.Component<
  IAddDialogProps,
  IAddDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      description: null,
      number: 1
    };
  }

  handleDescription = e => {
    this.setState({ description: e.target.value });
  };

  handleNumber = e => {
    this.setState({ number: e.target.value });
  };

  public render() {
    return (
      <div>
        <Header>Add referral code?</Header>
        <br />
        <Label>Number of Codes</Label>
        <Input
          value={this.state.number}
          onChange={this.handleNumber}
          type="number"
        />
        <br />
        <br />
        <Label>Enter Description</Label>
        <Input
          value={this.state.description}
          onChange={this.handleDescription}
        />
        <br />
        <br />
        <PrimaryButton
          onClick={() =>
            addCode(
              this.state.number,
              this.state.description,
              this.props.campaign.promo_campaign_id,
              this.props.closeModal,
              this.props.afterSave
            )
          }
          enabled={true}
        >
          Add
        </PrimaryButton>
      </div>
    );
  }
}

async function addCode(
  numberOfCodes,
  description,
  campaignID,
  closeModal,
  afterSave
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
  return response;
}
