import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import {
  Button,
} from "../../packs/style.jsx";

class CryptoPrivacyModal extends React.Component {
  constructor(props) {
    super(props);

    this.close = props.close;
    this.updateAddress = props.updateAddress;
    this.address = props.address;
  }
  
  render() {
    return (
      <div>
        <h1 className='privacy-header'><FormattedMessage id='walletServices.addCryptoWidget.privacyHeader' /></h1>
        <p className='privacy-text'><FormattedMessage id='walletServices.addCryptoWidget.privacyNotification' /></p>
        <div className='privacy-button-container'>
          <Button
            onClick={this.close}
            style={{ margin: "10px 0px", width: "320px" }}
            outline
          >
            <FormattedMessage id="walletServices.addCryptoWidget.privacyQuit" />
          </Button>
        </div>
        <div className='privacy-button-container'>
          <Button
            onClick={() => {this.updateAddress(this.address); this.close()}}
            style={{ margin: "10px 0px", width: "320px" }}
            primary
          >
            <FormattedMessage id="walletServices.addCryptoWidget.privacyContinue" />
          </Button>
        </div>
      </div>
    )
  }
}

export default injectIntl(CryptoPrivacyModal);
