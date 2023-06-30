import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import ErrorBoundary from "../../components/errorBoundary/ErrorBoundary";
import { FlexWrapper } from "../style";
import BraveConnection from "./BraveConnection";
import LastDepositInformation from "./LastDepositInformation";

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

        <ErrorBoundary>
          <LastDepositInformation />
        </ErrorBoundary>

        <hr />
        <ErrorBoundary>
          <BraveConnection featureFlags={this.props.featureFlags} />
        </ErrorBoundary>
      </div>
    );
  }
}

export default injectIntl(WalletServices);
