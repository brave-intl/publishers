import * as React from "react";
import { FormattedMessage } from "react-intl";

import routes from "../../routes";
import { FlexWrapper } from "../../style";
import GeminiIcon from "./geminiConnection/GeminiIcon";
import DisconnectPrompt from "./upholdConnection/UpholdDisconnectPrompt";
import { VerifyButton } from "./VerifyButton";

class GeminiConnection extends React.Component<any, any> {
  constructor(props) {
    super(props);

    const defaultCurrencyPresent =
      this.props.defaultCurrency && this.props.defaultCurrency.length !== 0;

    this.state = {
      error: null,
    };
  }

  public render() {
    const { oauth_refresh_failed, isPayable, recipientIdStatus, validCountry } = this.props

    const isDuplicate = recipientIdStatus === 'duplicate'
    const verifyUrl = oauth_refresh_failed || isDuplicate || !validCountry ? null : this.props.verifyUrl
    const statusId = oauth_refresh_failed || isDuplicate ? "walletServices.trouble" : "walletServices.connected"

    let messageId = null

    if (oauth_refresh_failed) {
      messageId = "walletServices.gemini.reauthorizationNeeded" 
    } else if (isDuplicate) {
      messageId = "walletServices.gemini.duplicateAccount" 
    } else if (!validCountry) {
      messageId = "walletServices.gemini.blocked_country"
    } else if (!isPayable) {
      // isPayable is based on GeminiConnection.payable? which requires a truthy recipient_id
      messageId = "walletServices.gemini.notPayable" 
    }
     
    const hasProblem =  (!isPayable || oauth_refresh_failed || isDuplicate || !validCountry) && messageId

    return (
      <div>
        <h6>
          <FormattedMessage id="walletServices.gemini.title" />
          <GeminiIcon />
        </h6>

        <div>
          {this.state.error && (
              <div className="alert alert-warning">{this.state.error} </div>
          )}

          {this.props.payoutFailed && (
              <div className="alert alert-warning">
                <FormattedMessage id="walletServices.brave.paymentFailedWarning" values={{
                  custodian: 'Gemini'
                }} />
              </div>
          )}

        <div className="row mb-2">
          <div className="col-6 text-dark text-truncate">
            <FormattedMessage
              id={statusId}
              values={{
                displayName: this.props.displayName,
                span: (chunks) => (
                  <span
                    style={{ color: "#19BA6A" }}
                    className="font-weight-bold"
                  >
                    @{chunks}
                  </span>
                ),
              }}
            />
          </div>

          <div className="col-1 d-none d-sm-block d-md-block">
            <span className="text-muted">|</span>
          </div>
          <div className="col-5">
            <FlexWrapper>
              <a
                className="btn btn-link p-0"
                rel="nofollow"
                data-method="delete"
                href={routes.publishers.gemini.destroy}
              >
                <FormattedMessage id="walletServices.gemini.disconnect" />
              </a>
            </FlexWrapper>
          </div>
        </div>
        {hasProblem &&  (
          <VerifyButton verifyUrl={verifyUrl}>
            <FormattedMessage id={messageId} values={{
              blocked_country_link: msg => (
                <a target='_blank' href='https://support.brave.com/hc/en-us/articles/9884338155149'>
                  <strong>{msg}</strong>
                </a>
              )
            }} />
          </VerifyButton>
        )}
        </div>
      </div>
    );
  }
}

export default GeminiConnection;
