import * as React from "react";

import locale from "../../../../locale/en";

import { Header, Label, PrimaryButton } from "./DeleteDialogStyle";

const initialState = { isLoading: false, errorText: "" };
type IDeleteDialogState = Readonly<typeof initialState>;

interface IDeleteDialogProps {
  closeModal: any;
  afterSave: () => void;
  codeID: any;
}

export default class DeleteDialog extends React.Component<
  IDeleteDialogProps,
  IDeleteDialogState
> {
  public readonly state: IDeleteDialogState = initialState;

  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <div>
        <Header>Delete referral code?</Header>
        <br />
        <Label>Please note, this action cannot be undone.</Label>
        <br />
        <br />
        <PrimaryButton
          enabled={true}
          onClick={() =>
            deleteCode(
              this.props.codeID,
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

async function deleteCode(codeID, closeModal, afterSave) {
  const url = "/partners/referrals/promo_registrations/" + codeID;
  const options = {
    method: "DELETE",
    headers: {
      Accept: "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRF-Token": document.head
        .querySelector("[name=csrf-token]")
        .getAttribute("content")
    }
  };
  let response = await fetch(url, options);
  afterSave();
  closeModal();
  return response;
}
