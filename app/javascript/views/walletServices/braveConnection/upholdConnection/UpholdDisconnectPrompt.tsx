import axios from "axios";
import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import routes from "../../../routes";

import { LoaderIcon } from "brave-ui/components/icons";
import { FlexWrapper } from "../../../style";

const DisconnectPrompt = (props) => {
  const [isLoading, setLoading] = React.useState(false);

  const confirmDisconnect = async () => {
    setLoading(true);
    axios
      .delete(routes.publishers.uphold.disconnect)
      .then(() => {
        setLoading(false);
        props.setShowModal(false);
        props.loadData();
      })
      .catch((err) => {
        setLoading(false);
        props.setShowModal(false);
        props.setError("We are unable to disconnect your wallet at this time.");
      });
  };

  return (
    <div>
      <h4>
        <FormattedMessage id="walletServices.uphold.disconnect.headline" />
      </h4>
      <p>
        <FormattedMessage id="walletServices.uphold.disconnect.intro" />
      </p>
      <p className="font-weight-bold">
        <FormattedMessage id="walletServices.uphold.disconnect.confirmation" />
      </p>
      <FlexWrapper>
        <a
          href="#"
          onClick={() => props.setShowModal(false)}
          className="btn btn-secondary"
        >
          <FormattedMessage id="walletServices.uphold.disconnect.deny" />
        </a>
        <a
          className="btn btn-secondary ml-2"
          onClick={() => confirmDisconnect()}
        >
          {isLoading && (
            <LoaderIcon style={{ width: "16px", margin: "0 5px" }} />
          )}
          <FormattedMessage id="walletServices.uphold.disconnect.confirm" />
        </a>
      </FlexWrapper>
    </div>
  );
};

export default DisconnectPrompt;
