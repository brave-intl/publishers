import * as React from "react";
import { FormattedMessage } from "react-intl";

import routes from "../../routes";
import { FlexWrapper } from "../../style";
import GeminiIcon from "./geminiConnection/GeminiIcon";
import { VerifyButton } from "./VerifyButton";
import Modal, { ModalSize } from "../../../components/modal/Modal";
import CurrencySelection from "./CurrencySelection";
import DisconnectPrompt from "./upholdConnection/UpholdDisconnectPrompt";

class GeminiConnection extends React.Component<any, any> {
  constructor(props) {
    super(props);

    const defaultCurrencyPresent =
      this.props.defaultCurrency && this.props.defaultCurrency.length !== 0;

    this.state = {
      error: null,
      showCurrencyModal: false, // (Albert): At the moment, we don't support the currency modal. Please revert once we do
    };
  }

  public render() {
    const { oauth_refresh_failed, isPayable, recipientIdStatus } = this.props

    const isDuplicate = recipientIdStatus === 'duplicate' 
    const verifyUrl = oauth_refresh_failed || isDuplicate ? null : this.props.verifyUrl
    const statusId = oauth_refresh_failed || isDuplicate ? "walletServices.trouble" : "walletServices.connected"

    let messageId = null

    if (oauth_refresh_failed) {
      messageId = "walletServices.gemini.reauthorizationNeeded" 
    } else if (isDuplicate) {
      messageId = "walletServices.gemini.duplicateAccount" 
    } else if (!isPayable) {
      // isPayable is based on GeminiConnection.payable? which requires a truthy recipient_id
      messageId = "walletServices.gemini.notPayable" 
    }

    const hasProblem =  (!isPayable || oauth_refresh_failed || isDuplicate) && messageId

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

        <div className="row">
          <div className="col-6 font-weight-bold">
            <FormattedMessage
              id="walletServices.uphold.depositCurrency"
              values={{
                currency: this.props.defaultCurrency,
                span: (...chunks) => (
                  <span
                    id="default_currency_code"
                    className="text-dark font-weight-normal"
                  >
                    {chunks}
                  </span>
                ),
              }}
            />
          </div>
          <div className="col-1 d-none d-sm-block d-md-block">
            <span className="text-muted">|</span>
          </div>
          <div className="col-5">
            <a href="#" onClick={() => this.showCurrencyModal(true)}>
              <FormattedMessage id="walletServices.uphold.change" />
            </a>

            <Modal
              show={this.state.showCurrencyModal}
              size={ModalSize.Small}
              handleClose={() => this.showCurrencyModal(false)}
            >
              <CurrencySelection
                setShowModal={this.showCurrencyModal}
                loadData={this.props.loadData}
                link={"https://gemini.com/fees/api-fee-schedule#api-fee"}
              />
            </Modal>
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

  private showCurrencyModal = (show) => {
    this.setState({ showCurrencyModal: show });
  };
}

export default GeminiConnection;
