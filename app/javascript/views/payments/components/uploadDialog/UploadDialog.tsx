import * as React from "react";

import locale from "../../../../locale/en";

import { Button } from "../../../style";

import { ErrorText, FlexWrapper, Input, Label } from "./UploadDialogStyle";

const initialState = { isLoading: false, errorText: "" };
type IUploadDialogState = Readonly<typeof initialState>;

interface IUploadDialogProps {
  route: string;
  text: string;
  setLoading: any;
  afterSave: any;
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
    this.props.setLoading(false);
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
      this.setState({ errorText: "" });
      this.props.afterSave(await result.json());
    } else {
      if (result.status === 500) {
        this.setState({
          errorText: locale.common.unexpectedError
        });
      } else {
        this.setState({ errorText: result.body.toString() });
      }
    }
    this.props.setLoading(false);
  }
  public render() {
    return (
      <FlexWrapper>
        <Label>
          <Button>{this.props.text}</Button>
          <Input
            type="file"
            id="upload"
            multiple
            onChange={this.uploadFile}
            accept=".pdf, .csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"
          />
        </Label>

        <ErrorText>{this.state.errorText}</ErrorText>
      </FlexWrapper>
    );
  }
}
