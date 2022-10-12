import * as React from "react";
import { FormattedMessage } from "react-intl";

const DepositCurrency = (props: any) => {
  return (
    <div className="row">
      <div className="col-6 font-weight-bold">
        <FormattedMessage
          id="walletServices.uphold.depositCurrency"
          values={{
            currency: props.defaultCurrency,
            span: (...chunks) => (
              <span
                id="default_currency_code"
                className="text-dark font-weight-normal"
              >
                {chunks}
              </span>
            ),
          }}
        />
      </div>
    </div>
  );
};

export default DepositCurrency;
