import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import { FlexWrapper } from "../style";
import BraveConnection from "./BraveConnection";
import StripeConnection from "./StripeConnection";

class WalletServices extends React.Component<any, any> {
  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <div>
        <h5>
          <FormattedMessage id="walletServices.title" />
        </h5>

        <LastDepositInformation />

        <hr />
        <BraveConnection featureFlags={this.props.featureFlags} />

        {this.props.featureFlags.stripe_enabled && (
          <React.Fragment>
            <hr />
            <StripeConnection />
          </React.Fragment>
        )}
      </div>
    );
  }
}

const LastDepositInformation = () => {
  return (
    <FlexWrapper>
      <div>
        <div className="font-weight-bold">
          <FormattedMessage
            id="walletServices.lastDeposit"
            values={{ value: "-" }}
          />
        </div>
        <div className="font-weight-bold">
          <FormattedMessage
            id="walletServices.lastDepositDate"
            values={{ value: "-" }}
          />
        </div>
      </div>
    </FlexWrapper>
  );
};

export default injectIntl(WalletServices);
