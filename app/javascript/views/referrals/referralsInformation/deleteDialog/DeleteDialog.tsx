import * as React from "react";

import locale from "../../../../locale/en";

import { Header, PrimaryButton } from "./DeleteDialogStyle";

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
  const url = "/partners/referrals/delete_codes?id=" + codeID;
  const options = {
    method: "GET",
    headers: {
      Accept: "application/json",
      "X-Requested-With": "XMLHttpRequest"
    }
  };
  let response = await fetch(url, options);
  afterSave();
  closeModal();
  return response;
}
