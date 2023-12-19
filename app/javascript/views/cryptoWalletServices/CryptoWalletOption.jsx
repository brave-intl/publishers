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
      formatCryptoAddress: this.props.selectProps.formatCryptoAddress,
      close: this.props.selectProps.onMenuClose,
    };
  }

  handleDelete(e) {
    e.stopPropagation();
    this.state.deleteAddress(this.state.value);
    this.state.close()
  }
  
  render() {
    if (this.state.value.hasOwnProperty('newAddress')) {
      return (
        <div {...this.state.innerProps} className="new-wallet-button">
          <span>{this.state.label}</span>
        </div>
      )
    } else if (this.state.value.hasOwnProperty('clearAddress')) {
      if (this.state.value.deletedAddress) {
        return (
          <div {...this.state.innerProps} className="new-wallet-button">
            <span>{this.state.label}</span>
          </div>
        )
      } else {
        return null;
      }
    } else {
      return (
        <div {...this.state.innerProps} className="address-option">
          <span>
            <span>{this.state.formatCryptoAddress(this.state.value.address)}</span>
          </span>
          <TrashOIcon className="trash-icon" onClick={this.handleDelete.bind(this)} />
        </div>
      )
    }
  }
}

export default injectIntl(CryptoWalletOption);
