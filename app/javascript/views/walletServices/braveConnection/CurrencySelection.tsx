import axios from "axios";
import * as React from "react";
import routes from "../../routes";

import { LoaderIcon } from "brave-ui/components/icons";
import { FormattedMessage } from "react-intl";
import img from "./currencySelection/img-currency-setting.png";
import { FlexWrapper } from "../../style";

const CurrencySelection = (props) => {
  const [isLoading, setLoading] = React.useState(true);
  const [currencies, setCurrencies] = React.useState([]);
  const [defaultCurrency, setDefaultCurrency] = React.useState("");

  React.useEffect(() => {
    axios.get(routes.publishers.connections.currency).then((response) => {
      setLoading(false);
      const { supported_currencies, default_currency } = response.data;
      setCurrencies(supported_currencies);
      setDefaultCurrency(default_currency);
    });
  }, []);

  return (
    <React.Fragment>
      <FlexWrapper>
        <div>
          <img src={img} />
        </div>
        <div>
          <h6>
            <FormattedMessage id="walletServices.currencies.title" />
          </h6>
          <p>
            <FormattedMessage id="walletServices.currencies.description" />
          </p>
        </div>
      </FlexWrapper>
      <label>
        <FormattedMessage id="walletServices.currencies.defaultCurrency" />
      </label>
      <select>
        {currencies.map((currency) => (
          <option>{currency}</option>
        ))}
      </select>

      {isLoading && <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />}
    </React.Fragment>
  );
};

export default CurrencySelection;
