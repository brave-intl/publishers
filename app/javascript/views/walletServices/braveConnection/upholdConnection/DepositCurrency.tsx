import * as React from "react";
import { FormattedMessage } from "react-intl";
import Modal, { ModalSize } from "../../../../components/modal/Modal";
import CurrencySelection from "../CurrencySelection";

const DepositCurrency = (props: any) => {
  const [showCurrencyModal, setShowCurrencyModal] = React.useState(!props.defaultCurrency)

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
      <div className="col-1 d-none d-sm-block d-md-block">
        <span className="text-muted">|</span>
      </div>
      <div className="col-5">
        <a href="#" onClick={() => setShowCurrencyModal(true)}>
          <FormattedMessage id="walletServices.uphold.change" />
        </a>

        <Modal
          show={showCurrencyModal}
          size={ModalSize.Small}
          handleClose={() => setShowCurrencyModal(false)}
        >
          <CurrencySelection
            setShowModal={setShowCurrencyModal}
            loadData={props.loadData}
            link="https://uphold.com/en/pricing"
          />
        </Modal>
      </div>
    </div>
  );
};

export default DepositCurrency;
