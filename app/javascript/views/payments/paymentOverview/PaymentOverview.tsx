import * as React from "react";

import locale from "../../../locale/en";
import { Header, Subheader } from "../../style";
import {
  Button,
  ButtonGroup,
  InactiveText,
  PaymentTotal,
  Text,
  Wrapper
} from "./style";

interface IPaymentOverviewProps {
  active: boolean;
  confirmationDate: string;
  paymentTotal: string;
  defaultCurrency: string;
}

export default class PaymentOverview extends React.Component<
  IPaymentOverviewProps
> {
  public static defaultProps = {
    active: true,
    confirmationDate: "Jan 31, 2018",
    defaultCurrency: "BAT",
    paymentTotal: "999.9"
  };

  public render() {
    const confirmedDate = locale.payments.overview.confirmationMessage.replace(
      "{date}",
      this.props.confirmationDate
    );

    const paymentTotal = this.props.active ? (
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
            <Button active={this.props.active}>
              {locale.payments.overview.uploadInvoice}
            </Button>
            <Button active={this.props.active}>
              {locale.payments.overview.uploadReport}
            </Button>
          </ButtonGroup>
        </section>
      </Wrapper>
    );
  }
}
