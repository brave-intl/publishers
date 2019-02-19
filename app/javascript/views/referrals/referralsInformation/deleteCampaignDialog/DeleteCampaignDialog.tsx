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
        <Header>{locale.referrals.deleteCampaign}</Header>
        <br />
        <Label>{locale.referrals.deleteCampaignNotice}</Label>
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
          {locale.delete}
        </PrimaryButton>
      </div>
    );
  }
}

async function DeleteCampaign(campaign, referralCodes, closeModal, afterSave) {
  const url =
    "/partners/referrals/promo_campaigns/" + campaign.promo_campaign_id;
  const body = new FormData();
  const codes = [];
  referralCodes.forEach(code => {
    codes.push(code.id);
  });
  body.append("codes", JSON.stringify(codes));
  const options = {
    body,
    headers: {
      Accept: "application/json",
      "X-CSRF-Token": document.head
        .querySelector("[name=csrf-token]")
        .getAttribute("content"),
      "X-Requested-With": "XMLHttpRequest"
    },
    method: "DELETE"
  };
  const response = await fetch(url, options);
  afterSave();
  closeModal();
  return response;
}
