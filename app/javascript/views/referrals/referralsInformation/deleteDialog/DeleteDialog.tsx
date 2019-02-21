import * as React from "react";

import locale from "../../../../locale/en";

import { ErrorText, Header, Label, PrimaryButton } from "./DeleteDialogStyle";

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

  public async deleteCode(codeID, closeModal, afterSave) {
    const url = "/partners/referrals/promo_registrations/" + codeID;
    const options = {
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
        <Header>{locale.referrals.deleteCode}</Header>
        <br />
        <Label>{locale.referrals.deleteNotice}</Label>
        <br />
        <br />
        <PrimaryButton
          enabled={true}
          onClick={() =>
            this.deleteCode(
              this.props.codeID,
              this.props.closeModal,
              this.props.afterSave
            )
          }
        >
          {locale.delete}
        </PrimaryButton>
        <ErrorText>{this.state.errorText}</ErrorText>
      </div>
    );
  }
}
