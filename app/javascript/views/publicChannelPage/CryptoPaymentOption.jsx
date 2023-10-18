import * as React from "react";
import { injectIntl } from "react-intl";
import { CryptoOption } from "./PublicChannelPageStyle.js";

class CryptoPaymentOption extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      label: this.props.label,
      value: this.props.value,
      innerProps: this.props.innerProps,
      icon: this.props.data.icon,
    };
  }
  
  render() {
    return (
      <CryptoOption {...this.state.innerProps} >
        <span>
          <img src={this.state.icon} />
          <span>{this.state.label}</span>
        </span>
      </CryptoOption>
    )
  }
}

export default injectIntl(CryptoPaymentOption);
