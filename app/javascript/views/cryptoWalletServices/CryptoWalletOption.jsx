import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import { TrashOIcon } from "brave-ui/components/icons";

class CryptoWalletOption extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      label: this.props.label,
      value: this.props.value,
      innerProps: this.props.innerProps,
      deleteAddress: this.props.selectProps.deleteAddress,
      formatCryptoAddress: this.props.selectProps.formatCryptoAddress
    };
  }
  
  render() {
    if (this.state.value.hasOwnProperty('newAddress')) {
      return (
        <div {...this.state.innerProps} className="new-wallet-button">
          <span>{this.state.label}</span>
        </div>
      )
    } else {
      return (
        <div {...this.state.innerProps} className="address-option">
          <span>
            <span>{this.state.formatCryptoAddress(this.state.value.address)}</span>
          </span>
          <TrashOIcon className="trash-icon" onClick={(e)=>{this.state.deleteAddress(this.state.value, e)}} />
        </div>
      )
    }
  }
}

export default injectIntl(CryptoWalletOption);
