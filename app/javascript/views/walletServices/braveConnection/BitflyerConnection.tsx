import * as React from "react";
import { FormattedMessage } from "react-intl";

import routes from "../../routes";
import { FlexWrapper } from "../../style";
import { VerifyButton } from "./VerifyButton";
import Modal, { ModalSize } from "../../../components/modal/Modal";
import CurrencySelection from "./CurrencySelection";
import BitflyerIcon from "./bitflyerConnection/BitflyerIcon";

class BitflyerConnection extends React.Component<any, any> {
    constructor(props) {
        super(props);

        const defaultCurrencyPresent =
            this.props.defaultCurrency && this.props.defaultCurrency.length !== 0;

        this.state = {
            error: null,
            showCurrencyModal: !defaultCurrencyPresent,
        };
    }

    public render() {
        return (
            <div>
                <h6>
                    <FormattedMessage id="walletServices.bitflyer.title" />
                    <BitflyerIcon />
                </h6>

                <div className="row mb-2">
                    <div className="col-6 text-dark text-truncate">
                        <FormattedMessage
                            id="walletServices.connected"
                            values={{
                                displayName: this.props.displayName,
                                span: (chunks) => (
                                    <span
                                        style={{ color: "#19BA6A" }}
                                        className="font-weight-bold"
                                    >
                                        @{chunks}
                                    </span>
                                ),
                            }}
                        />
                    </div>

                    <div className="col-1 d-none d-sm-block d-md-block">
                        <span className="text-muted">|</span>
                    </div>
                    <div className="col-5">
                        <FlexWrapper>
                            <a
                                className="btn btn-link p-0"
                                data-piwik-action="BitflyerDisconnectClicked"
                                data-piwik-name="Clicked"
                                data-piwik-value="Dashboard"
                                rel="nofollow"
                                data-method="delete"
                                href={routes.publishers.bitflyer.destroy}
                            >
                                <FormattedMessage id="walletServices.bitflyer.disconnect" />
                            </a>
                        </FlexWrapper>
                    </div>
                </div>

                <div className="row">
                    <div className="col-6 font-weight-bold">
                        <FormattedMessage
                            id="walletServices.uphold.depositCurrency"
                            values={{
                                currency: this.props.defaultCurrency,
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
                        <a href="#" onClick={() => this.showCurrencyModal(true)}>
                            <FormattedMessage id="walletServices.uphold.change" />
                        </a>

                        <Modal
                            show={this.state.showCurrencyModal}
                            size={ModalSize.Small}
                            handleClose={() => this.showCurrencyModal(false)}
                        >
                            <CurrencySelection
                                setShowModal={this.showCurrencyModal}
                                loadData={this.props.loadData}
                                link={"https://bitflyer.com/en-us/commission"}
                            />
                        </Modal>
                    </div>
                </div>
                {!this.props.isPayable && (
                    <VerifyButton verifyUrl={this.props.verifyUrl}>
                        <FormattedMessage id="walletServices.bitflyer.notPayable" />
                    </VerifyButton>
                )}
            </div>
        );
    }

    private showCurrencyModal = (show) => {
        this.setState({ showCurrencyModal: show });
    };
}

export default BitflyerConnection;
