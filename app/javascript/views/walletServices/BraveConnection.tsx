import axios from "axios";
import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import routes from "../routes";

import { LoaderIcon } from "brave-ui/components/icons";
import GeminiConnection from "./braveConnection/GeminiConnection";
import NotConnected from "./braveConnection/NotConnected";
import UpholdConnection from "./braveConnection/UpholdConnection";
import BitflyerConnection from "./braveConnection/BitflyerConnection";

// This class serves as the entry point for establishing a wallet connection.
// It allows users to establish a connection to different crypto wallet providers.
// Upon load makes a request to
class BraveConnection extends React.Component<any, any> {
  constructor(props) {
    super(props);

    this.state = {
      bitflyerConnection: {},
      geminiConnection: {},
      isLoading: true,
      locale: '',
      upholdConnection: {},
    };
  }

  public componentDidMount() {
    this.loadData();
  }

  public render() {
    // Show the loading component first
    if (this.state.isLoading) {
      return <LoadingComponent />;
      // If there's an uphold connection let's show the UpholdConnection component
    } else if (
      this.state.upholdConnection &&
      this.state.upholdConnection.uphold_id
    ) {
      return (
        <UpholdConnection
          defaultCurrency={this.state.upholdConnection.default_currency}
          upholdUsername={this.state.upholdConnection.username}
          status={this.state.upholdConnection.uphold_status}
          verifyUrl={this.state.upholdConnection.verify_url}
          canCreateCards={this.state.upholdConnection['can_create_uphold_cards?']}
          oauth_refresh_failed={this.state.upholdConnection.oauth_refresh_failed}
          loadData={this.loadData}
        />
      );
      // If there's an gemini connection let's show the GeminiConnection component
    } else if (
      this.props.featureFlags.gemini_enabled &&
      this.state.geminiConnection &&
      (this.state.geminiConnection.display_name || this.state.geminiConnection.oauth_refresh_failed)
    ) {
      return (
        <GeminiConnection
          defaultCurrency={this.state.geminiConnection.default_currency}
          displayName={this.state.geminiConnection.display_name}
          isPayable={this.state.geminiConnection["payable?"]}
          recipientIdStatus={this.state.geminiConnection['recipient_id_status']}
          verifyUrl={this.state.geminiConnection.verify_url}
          oauth_refresh_failed={this.state.geminiConnection.oauth_refresh_failed}
          loadData={this.loadData}
        />
      );
      // If there's a bitflyer connection let's show the BitflyerConnection component
    }
    else if (
      this.state.bitflyerConnection
    ) {
      return (
        <BitflyerConnection
          defaultCurrency={this.state.bitflyerConnection.default_currency}
          displayName={this.state.bitflyerConnection.display_name}
          isPayable={this.state.bitflyerConnection["payable?"]}
          verifyUrl={this.state.bitflyerConnection.verify_url}
          oauth_refresh_failed={this.state.bitflyerConnection.oauth_refresh_failed}
          loadData={this.loadData}
        />
      );
      // Finally if there was no wallets connected we should give the user the ability to connect.
    }
    else {
      return <NotConnected featureFlags={this.props.featureFlags} locale={this.state.locale} />;
    }
  }

  // Sets loading to true and makes a request to the wallet path in PublishersController#wallet
  private loadData = () => {
    this.setState({ isLoading: true });

    const locale = new URLSearchParams(window.location.search).get('locale');

    axios.get(routes.publishers.wallet.path).then((response) => {
      const newState = {
        bitflyerConnection: null,
        geminiConnection: null,
        isLoading: false,
        locale: locale,
        upholdConnection: null,
      };

      const { bitflyer_connection, uphold_connection, gemini_connection } = response.data;
      if (bitflyer_connection && bitflyer_connection.display_name) {
        newState.bitflyerConnection = response.data.bitflyer_connection;
      }
      if (uphold_connection && uphold_connection.uphold_id) {
        newState.upholdConnection = response.data.uphold_connection;
      }
      // We must notify users if their connection has failed regardless of whether the display name is present
      if (gemini_connection && (gemini_connection.display_name || gemini_connection.oauth_refresh_failed)) {
        newState.geminiConnection = response.data.gemini_connection;
      }

      this.setState({ ...newState });
    });
  };
}

const LoadingComponent = () => (
  <div>
    <h6>
      <FormattedMessage id="walletServices.brave.title" />
    </h6>

    <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />
  </div>
);

export default injectIntl(BraveConnection);
