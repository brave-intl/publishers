import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";

import Modal, { ModalSize } from "../../../components/modal/Modal";
import { FlexWrapper } from "../../style";
import DepositCurrency from "./upholdConnection/DepositCurrency";
import DisconnectPrompt from "./upholdConnection/UpholdDisconnectPrompt";
import UpholdIcon from "./upholdConnection/UpholdIcon";
import UpholdStatusMessage from "./upholdConnection/UpholdStatusMessage";

interface IUpholdConnectionState {
  showDisconnectModal: boolean;
  error?: string;
}

class UpholdConnection extends React.Component<any, IUpholdConnectionState> {
  constructor(props) {
    super(props);

    this.state = {
      error: null,
      showDisconnectModal: false,
    };
  }

  public render() {
    return (
      <React.Fragment>
        <h6>
          <FormattedMessage id="walletServices.uphold.title" />
          <UpholdIcon />
        </h6>
        <div>
          {this.state.error && (
            <div className="alert alert-warning">{this.state.error} </div>
          )}

          {this.props.payoutFailed && (
              <div className="alert alert-warning">
                <FormattedMessage id="walletServices.brave.paymentFailedWarning" values={{
                  custodian: 'Uphold'
                }} />
              </div>
          )}

          <div className="row mb-2">
            <div className="col-6 text-dark text-truncate">
              <FormattedMessage
                id="walletServices.connected"
                values={{
                  displayName: this.props.upholdUsername,
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
                  href="#"
                  onClick={() => this.setState({ showDisconnectModal: true })}
                  className="disconnect-uphold"
                >
                  <FormattedMessage id="walletServices.disconnect" />
                </a>
                <Modal
                  show={this.state.showDisconnectModal}
                  size={ModalSize.Small}
                  handleClose={() => this.showDisconnectModal(false)}
                >
                  <DisconnectPrompt
                    setError={this.setError}
                    loadData={this.props.loadData}
                    setShowModal={this.showDisconnectModal}
                  />
                </Modal>
              </FlexWrapper>
            </div>
          </div>

          {/*
            If a user can't create cards then we will show a status message,
            unless they are in "blocked" status.
          */}
          {this.props.canCreateCards && (
            <DepositCurrency
              loadData={this.props.loadData}
              defaultCurrency={this.props.defaultCurrency}
            />
          )}

          <UpholdStatusMessage
            verifyUrl={this.props.verifyUrl}
            status={this.props.status}
          />
        </div>
      </React.Fragment>
    );
  }

  private setError = (message) => {
    this.setState({ error: message });
  };

  private showDisconnectModal = (show) => {
    this.setState({ showDisconnectModal: show });
  };
}

export default injectIntl(UpholdConnection);
