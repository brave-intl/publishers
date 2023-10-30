import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import { 
  SuccessWrapper,
  ShareButton,
  PaymentButtons,
  QRLink,
  SuccessMessageWrapper,
  SuccessThank,
  SuccessAmount,
} from "./PublicChannelPageStyle.js";

class SuccessWidget extends React.Component {
  constructor(props) {
    super(props);

    const intl = props.intl;
    const tweetText = intl.formatMessage(
      {id: 'publicChannelPage.successTweet'},
      {url: window.location.href, name: this.props.name, symbol: this.props.chain}
    );

    this.state = {
      setStateToStart: props.setStateToStart,
      amount: props.amount,
      chain: props.chain,
      tweetText,
    }
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
          <ShareButton href={`https://twitter.com/intent/tweet?text=${this.state.tweetText}`} target="_blank" rel="noopener noreferrer">
            <FormattedMessage id="publicChannelPage.share" />
          </ShareButton>
          
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
