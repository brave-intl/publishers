import * as React from "react";

import locale from "../../../../locale/en";

import { Header, PrimaryButton } from "./AddDialogStyle";

const initialState = { isLoading: false, errorText: "" };
type IAddDialogState = Readonly<typeof initialState>;

interface IAddDialogProps {
  closeModal: () => void;
  campaign: any;
}

export default class AddDialog extends React.Component<
  IAddDialogProps,
  IAddDialogState
> {
  public readonly state: IAddDialogState = initialState;

  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <div>
        <Header>Add referral code?</Header>
        <br />
        <PrimaryButton
          onClick={() =>
            addCode(
              1,
              this.props.campaign.promo_campaign_id,
              this.props.closeModal
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

async function addCode(numberOfCodes, campaignID, closeModal) {
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
  closeModal();
  return response;
}
