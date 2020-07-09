import axios from "axios";
import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import routes from "../routes";

import { LoaderIcon } from "brave-ui/components/icons";
import NotConnected from "./braveConnection/NotConnected";
import UpholdConnection from "./braveConnection/UpholdConnection";
import GeminiConnection from "./braveConnection/GeminiConnection";

// This class serves as the entry point for establishing a wallet connection.
// It allows users to establish a connection to different crypto wallet providers.
// Upon load makes a request to
class BraveConnection extends React.Component<any, any> {
  constructor(props) {
    super(props);

    this.state = {
      geminiConnection: {},
      isLoading: true,
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
          is_payable={this.state.geminiConnection['payable?']}
          loadData={this.loadData}
        />
      );
      // If there's an gemini connection let's show the GeminiConnection component
    } else if (
      this.state.geminiConnection &&
      this.state.geminiConnection.id
    ) {
      return (
        <GeminiConnection
          defaultCurrency={this.state.geminiConnection.default_currency}
          displayName={this.state.geminiConnection.display_name}
          status={this.state.geminiConnection.uphold_status}
          loadData={this.loadData}
        />
      );
      // Finally if there was no wallets connected we should give the user the ability to connect.
    } else {
      return <NotConnected />;
    }
  }

  // Sets loading to true and makes a request to the wallet path in PublishersController#wallet
  private loadData = () => {
    this.setState({ isLoading: true });

    axios.get(routes.publishers.wallet.path).then((response) => {
      const newState = {
        geminiConnection: null,
        isLoading: false,
        upholdConnection: null,
      };

      if (response.data.uphold_connection.uphold_id) {
        newState.upholdConnection = response.data.uphold_connection;
      }
      if (response.data.gemini_connection.id) {
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
