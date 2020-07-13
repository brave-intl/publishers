import * as React from "react";
import { FormattedMessage } from "react-intl";

import routes from "../../routes";
import { FlexWrapper } from "../../style";
import GeminiIcon from "./geminiConnection/GeminiIcon";
import { VerifyButton } from "./VerifyButton";

class GeminiConnection extends React.Component<any, any> {
  constructor(props) {
    super(props);

    this.state = {};
  }

  public render() {
    return (
      <div>
        <h6>
          <FormattedMessage id="walletServices.gemini.title" />
          <GeminiIcon />
        </h6>

        <div className="row mb-2">
          <div className="col-6 text-dark text-truncate">
            <FormattedMessage
              id="walletServices.connected"
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
                className="btn btn-link p-0 ml-2"
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

        {!this.props.isPayable && (
          <VerifyButton verifyUrl={this.props.verifyUrl}>
             <FormattedMessage id="walletServices.gemini.notPayable" />
          </VerifyButton>
        )}
      </div>
    );
  }
}

export default GeminiConnection;
