import * as React from "react";

import locale from "../../../../locale/en";

import { Header, Input, Label, PrimaryButton } from "./AddDialogStyle";

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

  public handleDescription = e => {
    this.setState({ description: e.target.value });
  };

  public handleNumber = e => {
    this.setState({ number: e.target.value });
  };

  public isValidForm = () => {
    if (this.state.number > 0 && this.state.number < 500) {
      return true;
    } else {
      return false;
    }
  };

  public render() {
    return (
      <div>
        <Header>Add referral code?</Header>
        <br />
        <Label>Number of Codes</Label>
        <br />
        <Input
          style={{ width: "25%" }}
          value={this.state.number}
          onChange={this.handleNumber}
          type="number"
        />
        <br />
        <br />
        <Label>Enter Description</Label>
        <Input
          style={{ width: "100%" }}
          value={this.state.description}
          onChange={this.handleDescription}
          placeholder={"Say something about these codes"}
        />
        <br />
        <br />
        <br />
        {this.isValidForm() === true ? (
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
        ) : (
          <PrimaryButton enabled={false}>Add</PrimaryButton>
        )}
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
  afterSave();
  closeModal();
  return response;
}
