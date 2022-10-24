import * as React from "react";
import { FormattedMessage } from "react-intl";

import routes from "../../routes";
import { FlexWrapper } from "../../style";
import GeminiIcon from "./geminiConnection/GeminiIcon";
import { VerifyButton } from "./VerifyButton";
import DisconnectPrompt from "./upholdConnection/UpholdDisconnectPrompt";

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
    const { oauth_refresh_failed, isPayable, recipientIdStatus, valid_country } = this.props

    const isDuplicate = recipientIdStatus === 'duplicate'
    const verifyUrl = oauth_refresh_failed || isDuplicate ? null : this.props.verifyUrl
    const statusId = oauth_refresh_failed || isDuplicate ? "walletServices.trouble" : "walletServices.connected"

    let messageId = null

    if (oauth_refresh_failed) {
      messageId = "walletServices.gemini.reauthorizationNeeded" 
    } else if (isDuplicate) {
      messageId = "walletServices.gemini.duplicateAccount" 
    } else if (!valid_country) {
      messageId = "walletServices.gemini.blocked_country"
    } else if (!isPayable) {
      // isPayable is based on GeminiConnection.payable? which requires a truthy recipient_id
      messageId = "walletServices.gemini.notPayable" 
    }

    const hasProblem =  (!isPayable || oauth_refresh_failed || isDuplicate || !valid_country) && messageId

    return (
      <div>
        <h6>
          <FormattedMessage id="walletServices.gemini.title" />
          <GeminiIcon />
        </h6>

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
                data-piwik-action="GeminiDisconnectClicked"
                data-piwik-name="Clicked"
                data-piwik-value="Dashboard"
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
            <FormattedMessage id={messageId} />
          </VerifyButton>
        )}
      </div>
    );
  }
}

export default GeminiConnection;
