import * as moment from "moment";
import * as React from "react";

import locale from "../../../locale/en";
import routes from "../../routes";

import Modal, { ModalSize } from "../../../components/Modal";
import InvoiceShow from "../components/InvoiceShow";
import { IInvoice } from "../Payments";

import { Header, Subheader } from "../../style";
import {
  ButtonGroup,
  InactiveText,
  Input,
  OverviewButton,
  PaymentTotal,
  Text,
  Wrapper
} from "./PaymentOverviewStyle";

interface IPaymentOverviewProps {
  paymentTotal: string;
  inactive: boolean;
  invoices: IInvoice[];
  defaultCurrency: string;
  reloadInvoices: any;
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
    defaultCurrency: "BAT",
    inactive: false,
    paymentTotal: "0"
  };
  public readonly state: IPaymentOverviewState = {
    isLoading: false,
    showModal: false,
    showUpload: false
  };

  public render() {
    const confirmedDate = locale.payments.overview.confirmationMessage.replace(
      "{date}",
      moment()
        .endOf("month")
        .format("MMM DD, YYYY")
    );

    const paymentTotal = this.props.inactive ? (
      <InactiveText>{confirmedDate}</InactiveText>
    ) : (
      <React.Fragment>
        <Text>
          {this.props.invoices[0].finalizedAmount ||
            this.props.invoices[0].amount}
        </Text>
        <Subheader> {this.props.defaultCurrency}</Subheader>
      </React.Fragment>
    );

    let invoiceGroup;

    if (this.props.invoices && this.props.invoices.length > 0) {
      invoiceGroup = (
        <React.Fragment>
          <ButtonGroup>
            <OverviewButton
              inactive={this.props.inactive}
              onClick={this.triggerModal}
            >
              {locale.payments.overview.invoice}
            </OverviewButton>
          </ButtonGroup>

          <Modal
            handleClose={this.triggerModal}
            show={this.state.showModal}
            size={ModalSize.Small}
          >
            <InvoiceShow invoice={this.props.invoices[0]} />
          </Modal>
        </React.Fragment>
      );
    }

    return (
      <Wrapper>
        <section>
          <Header>{locale.payments.overview.nextPaymentDate}</Header>
          <Text>{this.nextPaymentDate()}</Text>
        </section>

        <section>
          <Header>{locale.payments.overview.paymentTotal}</Header>
          <PaymentTotal>{paymentTotal}</PaymentTotal>
          {invoiceGroup}
        </section>
      </Wrapper>
    );
  }
  private navigateToInvoices = () => {
    window.location.href = routes.payments.invoices.path;
  };

  private setLoading = () => {
    this.setState({ isLoading: true });
  };

  private nextPaymentDate = () => {
    let date;

    if (this.props.invoices && this.props.invoices[0]) {
      date = this.props.invoices[0].date;
      date = moment(date, "MMMM YYYYY").add(1, "M");
    } else {
      date = moment().add(1, "M");
    }

    date = date.format("MMMM 8, YYYY");
    return <span>{date}</span>;
  };

  private triggerModal = () => {
    this.setState({ showModal: !this.state.showModal });
    this.props.reloadInvoices();
  };
}
