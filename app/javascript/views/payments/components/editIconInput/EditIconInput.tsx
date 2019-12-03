import * as React from "react";

import locale from "../../../../locale/en";

import EditIcon from "./editIcon/EditIcon";

import {
  ErrorText,
  FlexWrapper,
  InputComponent,
  InputContainer,
  PrimaryButton,
  StyledInput,
  Text
} from "./EditIconInputStyle";

import { Subheader } from "../../../style";

interface IInputState {
  errorText: string;
  isEditing: boolean;
  savedValue: string;
  value: string;
}
interface IInputProps {
  initialValue: string;
  disabled: boolean;
  onSave(value: string): Promise<object>;
}

export default class EditIconInput extends React.Component<
  IInputProps,
  IInputState
> {
  public static defaultProps = { value: "" };

  public readonly state: IInputState = {
    errorText: "",
    isEditing: false,
    savedValue: this.props.initialValue,
    value: this.props.initialValue
  };

  private textInput: React.RefObject<HTMLInputElement>;
  private containerRef: React.RefObject<HTMLInputElement>;

  constructor(props) {
    super(props);
    this.textInput = React.createRef();
    this.containerRef = React.createRef();
  }

  public componentDidMount() {
    document.addEventListener("mousedown", this.handleClickOutside);
  }

  public componentDidUpdate() {
    if (this.textInput && this.textInput.current) {
      this.textInput.current.focus();
    }
  }

  public componentWillUnmount() {
    document.removeEventListener("mousedown", this.handleClickOutside);
  }

  public handleClickOutside = e => {
    if (!this.containerRef.current.contains(e.target)) {
      this.resetValue();
    }
  };

  public render() {
    return (
      <FlexWrapper ref={this.containerRef}>
        {this.state.isEditing ? this.renderEdit() : this.renderDisplay()}
      </FlexWrapper>
    );
  }

  private renderDisplay() {
    let edit: JSX.Element;

    if (!this.props.disabled) {
      edit = (
        <EditIcon
          style={{
            cursor: "pointer",
            fill: "#B8B9C4",
            marginLeft: "0.5rem",
            width: "18"
          }}
          onClick={this.editMode}
        />
      );
    }

    return (
      <InputContainer>
        <Text>{this.state.value}</Text>
        <Subheader>BAT</Subheader>
        {edit}
      </InputContainer>
    );
  }

  private renderEdit() {
    return (
      <React.Fragment>
        <InputContainer>
          {/*
            The input components were stolen from brave-ui until you can pass references and other attributes into the input
            https://github.com/brave/brave-ui/issues/373
           */}
          <InputComponent>
            <StyledInput
              ref={this.textInput}
              type="number"
              maxLength={24}
              value={this.state.value}
              onKeyPress={this.handleKeyPress}
              onChange={this.onChange}
            />
          </InputComponent>
        </InputContainer>
        <PrimaryButton onClick={this.inputSave}>Save</PrimaryButton>
        <ErrorText>{this.state.errorText}</ErrorText>
      </React.Fragment>
    );
  }

  private handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      this.inputSave();
    }
  };

  private resetValue = () => {
    if (this.state.value === "") {
      this.setState({
        errorText: locale.payments.invoices.upload.missing
      });
      return;
    }

    this.setState({
      errorText: "",
      isEditing: false,
      value: this.state.savedValue
    });
  };

  private inputSave = () => {
    if (this.state.value === "") {
      this.setState({
        errorText: locale.payments.invoices.upload.missing
      });
      return;
    }

    this.props
      .onSave(this.state.value)
      .then(result => {
        this.setState({
          errorText: "",
          isEditing: false,
          savedValue: this.state.value
        });
      })
      .catch(() =>
        this.setState({
          errorText: locale.common.unexpectedError
        })
      );
  };

  private editMode = event => {
    this.setState({ isEditing: true });
  };

  private onChange = event => {
    if (event.target.value === "") {
      this.setState({
        errorText: locale.payments.invoices.upload.missing,
        value: event.target.value
      });
    } else {
      this.setState({ value: event.target.value, errorText: "" });
    }
  };
}
