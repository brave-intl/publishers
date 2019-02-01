import * as React from "react";

import Input from "brave-ui/components/formControls/input";

import locale from "../../../locale/en";
import routes from "../../routes";

import {
  ErrorText,
  FlexWrapper,
  FormElement,
  Header,
  Label,
  PrimaryButton
} from "./ReportDialogStyle";

interface IReportDialogState {
  file: any;
  amountBAT: string;
  errorText: string;
  isValid: boolean;
}

interface IUploadDialogProps {
  route: string;
  setLoading: any;
  closeModal: () => void;
  afterSave: () => void;
}

export default class UploadDialog extends React.Component<
  IUploadDialogProps,
  IReportDialogState
> {
  public readonly state: IReportDialogState = {
    amountBAT: "",
    errorText: "",
    file: undefined,
    isValid: false
  };

  constructor(props) {
    super(props);
    this.upload = this.upload.bind(this);
  }

  public componentDidUpdate() {
    if (this.state.file && this.state.amountBAT && !this.state.isValid) {
      this.setState({ isValid: true });
    } else if (
      this.state.isValid &&
      (!this.state.file || !this.state.amountBAT)
    ) {
      this.setState({ isValid: false });
    }
  }
  public onChange = event => {
    this.setState({ amountBAT: event.target.value });
  };

  public setFile = event => {
    this.setState({ file: event.target.files[0] });
  };

  public submitForm = () => {
    if (!this.state.isValid) {
      return;
    }
    this.upload();
  };

  public async upload() {
    this.props.setLoading(false);

    const data = new FormData();
    data.append("amount_bat", this.state.amountBAT);
    data.append("file", this.state.file);

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
      this.props.closeModal();
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
      <div>
        <Header>{locale.payments.reports.upload.title}</Header>
        <p>{locale.payments.reports.upload.description}</p>
        <FormElement>
          <Label>{locale.payments.reports.upload.amountBAT}</Label>
          <Input onChange={this.onChange} value={this.state.amountBAT} />
        </FormElement>
        <FormElement>
          <input
            type="file"
            id="upload"
            onChange={this.setFile}
            accept=".pdf, .csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"
          />
        </FormElement>
        {this.state.errorText ? (
          <ErrorText>{this.state.errorText}</ErrorText>
        ) : (
          ""
        )}

        <FlexWrapper>
          <PrimaryButton onClick={this.submitForm} enabled={this.state.isValid}>
            {locale.payments.reports.upload.button}
          </PrimaryButton>
        </FlexWrapper>
      </div>
    );
  }
}
