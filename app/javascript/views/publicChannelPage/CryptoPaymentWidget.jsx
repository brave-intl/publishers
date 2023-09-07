import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import {
  CryptoWidgetWrapper,
} from "./PublicChannelPageStyle.js";

class CryptoPaymentWidget extends React.Component {
  constructor(props) {
    super(props);
  }
  
  render() {
    return (
      <CryptoWidgetWrapper>
        <p>this is the crypto widget</p>
      </CryptoWidgetWrapper>
    )
  }
}

export default injectIntl(CryptoPaymentWidget);
