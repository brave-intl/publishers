import axios from "axios";
import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";

import routes from "../routes";

import { LoaderIcon } from "brave-ui/components/icons";
import { FlexWrapper } from "../style";

import Modal, { ModalSize } from "../../components/modal/Modal";

interface IStripeConnectionState {
  detailsSubmitted: false;
  displayName: string;
  isLoading: boolean;
  payoutsEnabled: boolean;
  stripeUserId: string;
}

class StripeConnection extends React.Component<any, IStripeConnectionState> {
  constructor(props) {
    super(props);
    this.state = {
      detailsSubmitted: false,
      displayName: "",
      isLoading: false,
      payoutsEnabled: false,
      stripeUserId: null,
    };
  }

  public componentDidMount() {
    this.reload();
  }

  public render() {
    return (
      <React.Fragment>
        <h5>
          <FormattedMessage id="walletServices.stripe.title" />
        </h5>

        {this.state.isLoading && (
          <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />
        )}

        {this.state.stripeUserId === null && <NotConnected />}
        {this.state.stripeUserId && (
          <Connected
            displayName={this.state.displayName}
            payoutsEnabled={this.state.payoutsEnabled}
          />
        )}
      </React.Fragment>
    );
  }

  // This function connects to the backend server and loads the data from the StripeConnections#show function.
  private reload = async () => {
    this.setState({ isLoading: true });

    axios.get(routes.publishers.stripe.show).then((response) => {
      this.setState({
        displayName: response.data.display_name,
        isLoading: false,
        payoutsEnabled: response.data.payouts_enabled,
        stripeUserId: response.data.stripe_user_id,
      });
    });
  };
}

const Connected = (props) => (
  <React.Fragment>
    <FlexWrapper className="align-items-center">
      <span className="text-dark">
        <FormattedMessage
          id="walletServices.connected"
          values={{
            displayName: props.displayName,
            span: (chunks) => (
              <span style={{ color: "#19BA6A" }} className="font-weight-bold">
                @{chunks}
              </span>
            ),
          }}
        />
      </span>
      <span className="mx-2 text-muted d-none d-sm-block d-md-block">|</span>
      <a
        className="btn btn-link p-0 ml-2"
        data-piwik-action="StripeDisconnectClicked"
        data-piwik-name="Clicked"
        data-piwik-value="Dashboard"
        rel="nofollow"
        data-method="delete"
        href={routes.publishers.stripe.destroy}
      >
        <FormattedMessage id="walletServices.stripe.disconnect" />
      </a>
    </FlexWrapper>

    {!props.payoutsEnabled && (
      <span>
        <FormattedMessage id="walletServices.stripe.enablePayouts" />
      </span>
    )}
  </React.Fragment>
);

const NotConnected = () => (
  <div className="row">
    <div className="col-6">
      <FormattedMessage id="walletServices.stripe.description" />
    </div>
    <div className="col-6">
      <div className="d-flex justify-content-end">
        <a
          className="btn btn-secondary font-weight-bold"
          data-piwik-action="StripeConnectClicked"
          data-piwik-name="Clicked"
          data-piwik-value="Dashboard"
          rel="nofollow"
          data-method="post"
          href={routes.publishers.stripe.connect}
        >
          <FormattedMessage id="walletServices.stripe.connect" />
        </a>
      </div>
    </div>
  </div>
);

export default injectIntl(StripeConnection);
