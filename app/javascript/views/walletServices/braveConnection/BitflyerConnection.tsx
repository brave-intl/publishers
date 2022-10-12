import * as React from "react";
import { FormattedMessage } from "react-intl";

import routes from "../../routes";
import { FlexWrapper } from "../../style";
import { VerifyButton } from "./VerifyButton";
import BitflyerIcon from "./bitflyerConnection/BitflyerIcon";

class BitflyerConnection extends React.Component<any, any> {
    constructor(props) {
        super(props);

        const defaultCurrencyPresent =
            this.props.defaultCurrency && this.props.defaultCurrency.length !== 0;

        this.state = {
            error: null,
        };
    }

    public render() {
      const { oauth_refresh_failed, isPayable } = this.props

      const verifyUrl = oauth_refresh_failed ? null : this.props.verifyUrl
      const statusId = oauth_refresh_failed ? "walletServices.trouble" : "walletServices.connected"

      let messageId = null

      if (oauth_refresh_failed) {
        messageId = "walletServices.bitflyer.reauthorizationNeeded" 
      } else if (!isPayable) {
        messageId = "walletServices.bitflyer.notPayable"
      }

      const hasProblem =  (!isPayable || oauth_refresh_failed) && messageId

        return (
            <div>
                <h6>
                    <FormattedMessage id="walletServices.bitflyer.title" />
                    <BitflyerIcon />
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
                                data-piwik-action="BitflyerDisconnectClicked"
                                data-piwik-name="Clicked"
                                data-piwik-value="Dashboard"
                                rel="nofollow"
                                data-method="delete"
                                href={routes.publishers.bitflyer.destroy}
                            >
                                <FormattedMessage id="walletServices.bitflyer.disconnect" />
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
                </div>
                {hasProblem && (
                    <VerifyButton verifyUrl={verifyUrl}>
                        <FormattedMessage id={messageId} />
                    </VerifyButton>
                )}
            </div>
        );
    }
}

export default BitflyerConnection;
