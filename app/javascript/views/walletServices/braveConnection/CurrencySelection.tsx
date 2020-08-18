import axios from "axios";
import * as React from "react";
import { FormattedMessage, useIntl } from "react-intl";
import routes from "../../routes";

import { LoaderIcon } from "brave-ui/components/icons";
import { FlexWrapper } from "../../style";
import img from "./currencySelection/img-currency-setting.png";

const CurrencySelection = (props) => {
  const BAT = "BAT";
  const intl = useIntl();
  const [isLoading, setLoading] = React.useState(true);
  const [errors, setErrors] = React.useState([]);
  const [currencies, setCurrencies] = React.useState([]);
  const [defaultCurrency, setDefaultCurrency] = React.useState(BAT);

  React.useEffect(() => {
    axios.get(routes.publishers.connections.currency).then((response) => {
      setLoading(false);
      const { supported_currencies, default_currency } = response.data;
      setCurrencies(supported_currencies);
      setDefaultCurrency(default_currency || BAT);
    });
  }, []);

  const saveDefaultCurrency = (event) => {
    event.preventDefault();
    axios
      .patch(routes.publishers.connections.currency, {
        default_currency: defaultCurrency,
      })
      .then(() => {
        props.setShowModal(false);
        props.loadData();
      })
      .catch((axiosError) => {
        let error = axiosError.response.data.errors;
        if (error.length === 0) {
          error = [intl.formatMessage({ id: "common.unexpectedError" })];
        }
        setErrors(error);
      });
  };

  return (
    <React.Fragment>
      <FlexWrapper className="flex-column align-items-center text-center">
        {errors &&
          errors.map((error) => (
            <div key={error} className="my-2 alert alert-warning">
              {error}
            </div>
          ))}
        <div className="my-4">
          <img src={img} />
        </div>
        <h6>
          <FormattedMessage id="walletServices.currencies.title" />
        </h6>

        <p>
          <FormattedMessage id="walletServices.currencies.description" />
        </p>
        {isLoading && (
          <LoaderIcon
            style={{ width: "36px", height: "36px", margin: "0 auto" }}
          />
        )}
        {!isLoading && (
          <select
            className="mt-2"
            value={defaultCurrency}
            onChange={(event) => setDefaultCurrency(event.target.value)}
          >
            {currencies.map((currency) => (
              <option key={currency} value={currency}>
                {currency}
              </option>
            ))}
          </select>
        )}

        {defaultCurrency !== BAT && (
          <span className="alert alert-warning mt-2 text-left">
          <FormattedMessage
            id="walletServices.currencies.fees"
            values={{
              a: (chunks) => <a target="_blank" href={props.link}>{chunks}</a>,
            }}
          />
          </span>
        )}

        <a
          href="#"
          className="btn btn-primary mt-4"
          onClick={saveDefaultCurrency}
        >
          <FormattedMessage id="shared.save" />
        </a>
      </FlexWrapper>
    </React.Fragment>
  );
};

export default CurrencySelection;
