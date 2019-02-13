import * as React from "react";

import locale from "../../../../locale/en";

import { Header, Label, PrimaryButton } from "./DeleteCampaignDialogStyle";

const initialState = { isLoading: false, errorText: "" };
type IDeleteCampaignDialogState = Readonly<typeof initialState>;

interface IDeleteCampaignDialogProps {
  closeModal: any;
  afterSave: () => void;
  campaign: any;
  referralCodes: any;
}

export default class DeleteCampaignDialog extends React.Component<
  IDeleteCampaignDialogProps,
  IDeleteCampaignDialogState
> {
  public readonly state: IDeleteCampaignDialogState = initialState;

  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <div>
        <Header>Delete Campaign?</Header>
        <br />
        <Label>
          Please note, this action will delete all referral codes belonging to{" "}
          {this.props.campaign.name}. This action cannot be undone.
        </Label>
        <br />
        <br />
        <br />
        <PrimaryButton
          enabled={true}
          onClick={() =>
            DeleteCampaign(
              this.props.campaign,
              this.props.referralCodes,
              this.props.closeModal,
              this.props.afterSave
            )
          }
        >
          Delete
        </PrimaryButton>
      </div>
    );
  }
}

async function DeleteCampaign(campaign, referralCodes, closeModal, afterSave) {
  const url =
    "/partners/referrals/promo_campaigns/" + campaign.promo_campaign_id;
  let body = new FormData();
  let codes = [];
  referralCodes.forEach(function(code) {
    codes.push(code.id);
  });
  body.append("codes", JSON.stringify(codes));
  let options = {
    method: "DELETE",
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
