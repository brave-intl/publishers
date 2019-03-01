import * as React from "react";

import locale from "../../../../locale/en";

import {
  ErrorText,
  Header,
  Input,
  Label,
  PrimaryButton
} from "./AddDialogStyle";

const initialState = { isLoading: false, errorText: "" };

interface IAddDialogProps {
  closeModal: () => void;
  afterSave: () => void;
  campaign: any;
}

interface IAddDialogState {
  description: any;
  number: any;
  errorText: string;
}

export default class AddDialog extends React.Component<
  IAddDialogProps,
  IAddDialogState
> {
  constructor(props) {
    super(props);
    this.state = {
      description: null,
      errorText: "",
      number: 1
    };
  }

  public handleDescription = e => {
    this.setState({ description: e.target.value });
  };

  public handleNumber = e => {
    this.setState({ number: e.target.value });
  };

  public handleErrorText = text => {
    this.setState({ errorText: text });
  };

  public isValidForm = () => {
    if (this.state.number > 0 && this.state.number < 500) {
      return true;
    } else {
      return false;
    }
  };

  public async addCode(
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
        <Header>{locale.referrals.addReferralCodes}</Header>
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
          <PrimaryButton
            onClick={() =>
              this.addCode(
                this.state.number,
                this.state.description,
                this.props.campaign.promo_campaign_id,
                this.props.closeModal,
                this.props.afterSave
              )
            }
            enabled={true}
          >
            {locale.add}
          </PrimaryButton>
        ) : (
          <PrimaryButton enabled={false}>{locale.add}</PrimaryButton>
        )}
        <ErrorText>{this.state.errorText}</ErrorText>
      </div>
    );
  }
}
