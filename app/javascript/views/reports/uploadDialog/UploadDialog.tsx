import * as React from "react";

import locale from "../../../locale/en";
import routes from "../../routes";
import { Button } from "../../style";

import {
  ErrorText,
  FlexWrapper,
  Input,
  Label,
  LoadingIcon
} from "./UploadDialogStyle";

const initialState = { isLoading: false, errorText: "" };
type IUploadDialogState = Readonly<typeof initialState>;

interface IUploadDialogProps {
  route: string;
  text: string;
  afterSave: () => void;
}

export default class UploadDialog extends React.Component<
  IUploadDialogProps,
  IUploadDialogState
> {
  public readonly state: IUploadDialogState = initialState;

  constructor(props) {
    super(props);
    this.uploadFile = this.uploadFile.bind(this);
  }

  public async uploadFile(event) {
    this.setState({ isLoading: true });
    const file = event.target.files[0];

    const data = new FormData();
    data.append("file", file);

    const result = await fetch(this.props.route, {
      body: data,
      headers: {
        Accept: "text/html",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "POST"
    });

    if (result.ok) {
      this.props.afterSave();
    } else {
      if (result.status === 500) {
        this.setState({
          errorText: locale.common.unexpectedError
        });
      } else {
        this.setState({ errorText: result.body.toString() });
      }
    }
    this.setState({ isLoading: false });
  }
  public render() {
    return (
      <FlexWrapper>
        <Label>
          <Button>{this.props.text}</Button>
          <Input
            type="file"
            id="upload"
            onChange={this.uploadFile}
            accept=".pdf, .csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"
          />
        </Label>

        <LoadingIcon isLoading={this.state.isLoading} />
        <ErrorText>{this.state.errorText}</ErrorText>
      </FlexWrapper>
    );
  }
}
