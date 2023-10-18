import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import { 
  SuccessWrapper,
  SendButton,
  PaymentButtons,
  QRLink,
  SuccessMessageWrapper,
  SuccessThank,
  SuccessAmount,
} from "./PublicChannelPageStyle.js";

class SuccessWidget extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      setStateToStart: props.setStateToStart,
      amount: props.amount,
      chain: props.chain,
    }
  }

  shareSupport(){
    // ????
  }
  
  render() {
    return (
      <SuccessWrapper>
        <SuccessMessageWrapper>
          <SuccessAmount>
            <FormattedMessage id="publicChannelPage.hooray" values={{amount: `${this.state.amount} ${this.state.chain}`}}/>
          </SuccessAmount>
          <SuccessThank>
            <FormattedMessage id="publicChannelPage.thanks" />
          </SuccessThank>
        </SuccessMessageWrapper>
        <PaymentButtons>
          <SendButton onClick={(event) => {
            event.preventDefault();
            this.shareSupport();
          }}>
            <FormattedMessage id="publicChannelPage.share" />
          </SendButton>
          
          <QRLink onClick={(event) => {
            event.preventDefault();
            this.state.setStateToStart();
          }}>
            <FormattedMessage id="publicChannelPage.goBack" />
          </QRLink>
        </PaymentButtons>
      </SuccessWrapper>
    )
  }
}

export default injectIntl(SuccessWidget);
