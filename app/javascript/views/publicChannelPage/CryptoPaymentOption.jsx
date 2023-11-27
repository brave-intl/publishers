import * as React from "react";
import { injectIntl } from "react-intl";
import { CryptoOption, CryptoOptionSubheading, CryptoOptionText } from "./PublicChannelPageStyle.js";

class CryptoPaymentOption extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      label: this.props.label,
      value: this.props.value,
      innerProps: this.props.innerProps,
      icon: this.props.data.icon,
      subheading: this.props.data.subheading,
    };
  }
  
  render() {
    return (
      <CryptoOption {...this.state.innerProps} >
        <span>
          <img src={this.state.icon} />
          <CryptoOptionText>
            <span>{this.state.label}</span>
            <CryptoOptionSubheading>{this.state.subheading}</CryptoOptionSubheading>
          </ CryptoOptionText>
        </span>
      </CryptoOption>
    )
  }
}

export default injectIntl(CryptoPaymentOption);
