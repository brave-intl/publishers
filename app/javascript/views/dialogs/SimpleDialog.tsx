import * as React from "react";
import {
  Header,
  Label
} from "./SimpleDialogStyle";

interface ISimpleProps {
  header: string;
  label: string;
}

interface ISimpleState {
  header: string;
  label: string;
}

export default class SimpleDialog extends React.Component<ISimpleProps, ISimpleState> {
  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <div>
        <Header>{this.props.header}</Header>
        <Label>{this.props.label}</Label>
      </div>
    );
  }
}
