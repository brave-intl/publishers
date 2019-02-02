import * as React from "react";

import locale from "../../../locale/en";
import { Header, Subheader } from "../../style";
import {
  ButtonGroup,
  InactiveText,
  Input,
  OverviewButton,
  PaymentTotal,
  Text,
  Wrapper
} from "./paymentOverviewStyle";

import Modal, { ModalSize } from "../../../components/Modal";
import UploadDialog from "../../invoices/uploadDialog/UploadDialog";
import ReportDialog from "../../reports/reportDialog/ReportDialog";

import routes from "../../routes";

interface IPaymentOverviewProps {
  confirmationDate: string;
  paymentTotal: string;
  inactive: boolean;
  defaultCurrency: string;
}

interface IPaymentOverviewState {
  isLoading: boolean;
  showModal: boolean;
  showUpload: boolean;
}
export default class PaymentOverview extends React.Component<
  IPaymentOverviewProps,
  IPaymentOverviewState
> {
  public static defaultProps = {
    confirmationDate: "Jan 31, 2018",
    defaultCurrency: "BAT",
    inactive: false,
    paymentTotal: "999.9"
  };
  public readonly state: IPaymentOverviewState = {
    isLoading: false,
    showModal: false,
    showUpload: false
  };

  public render() {
    const confirmedDate = locale.payments.overview.confirmationMessage.replace(
      "{date}",
      this.props.confirmationDate
    );

    const paymentTotal = this.props.inactive ? (
      <React.Fragment>
        <Text>{this.props.paymentTotal}</Text>
        <Subheader> {this.props.defaultCurrency}</Subheader>
      </React.Fragment>
    ) : (
      <InactiveText>{confirmedDate}</InactiveText>
    );

    return (
      <Wrapper>
        <section>
          <Header>{locale.payments.overview.nextPaymentDate}</Header>
          <Text>Feb 8th, 2019</Text>
        </section>

        <section>
          <Header>{locale.payments.overview.paymentTotal}</Header>
          <PaymentTotal>{paymentTotal}</PaymentTotal>

          <ButtonGroup>
            <UploadDialog
              route={routes.payments.invoices.path}
              text={locale.payments.invoices.upload}
              afterSave={this.navigateToInvoice}
              setLoading={this.setLoading}
            />
            <OverviewButton
              inactive={this.props.inactive}
              onClick={this.triggerModal}
            >
              {locale.payments.overview.uploadReport}
            </OverviewButton>
          </ButtonGroup>

          <Modal
            handleClose={this.triggerModal}
            show={this.state.showModal}
            size={ModalSize.Small}
          >
            <ReportDialog
              route={routes.payments.reports.path}
              afterSave={this.navigateToReports}
              setLoading={this.setLoading}
              closeModal={this.triggerModal}
            />
          </Modal>
        </section>
      </Wrapper>
    );
  }
  private navigateToInvoice = () => {
    window.location.href = routes.payments.invoices.path;
  };

  private navigateToReports = () => {
    window.location.href = routes.payments.reports.path;
  };

  private setLoading = () => {
    this.setState({ isLoading: true });
  };

  private triggerModal = () => {
    this.setState({ showModal: !this.state.showModal });
  };
}
