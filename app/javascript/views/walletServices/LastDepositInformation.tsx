import axios from "axios";
import * as moment from "moment";
import * as React from "react";
import routes from "../routes";

import { LoaderIcon } from "brave-ui/components/icons";
import { FormattedMessage, injectIntl } from "react-intl";
import { FlexWrapper } from "../style";

const LastDepositInformation = () => {
  const [lastDeposit, setLastDeposit] = React.useState("-");
  const [settlementCurrency, setSettlementCurrency] = React.useState();
  const [lastDepositDate, setLastDepositDate] = React.useState("-");
  const [isLoading, setLoading] = React.useState(true);
  const [error, setError] = React.useState(null);

  React.useEffect(() => {
    requestLastDeposit();
  }, []);

  const requestLastDeposit = () => {
    axios
      .get(routes.publishers.wallet.latest)
      .then((response) => {
        const {
          amount_settlement_currency,
          settlement_currency,
          timestamp,
        } = response.data.lastSettlement;

        if (amount_settlement_currency && timestamp) {
          const time = moment.unix(timestamp).format("YYYY-MM-DD");
          setLastDeposit(amount_settlement_currency);
          setSettlementCurrency(settlement_currency);
          setLastDepositDate(time);
        }
        setLoading(false);
      })
      .catch((e) => {
        setError(e.response);
        setLoading(false);
      });
    return null;
  };

  return (
    <FlexWrapper>
      {error && <p>{error}</p>}
      {isLoading && <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />}
      {!isLoading && (
        <div>
          <div className="font-weight-bold">
            <FormattedMessage
              id="walletServices.lastDeposit"
              values={{
                span: (chunks) => (
                  <span className="font-weight-normal">{chunks} {settlementCurrency}</span>
                ),
                value: lastDeposit,
              }}
            />
          </div>
          <div className="font-weight-bold">
            <FormattedMessage
              id="walletServices.lastDepositDate"
              values={{
                span: (chunks) => (
                  <span className="font-weight-normal">{chunks}</span>
                ),
                value: lastDepositDate,
              }}
            />
          </div>
        </div>
      )}
    </FlexWrapper>
  );
};

export default LastDepositInformation;
