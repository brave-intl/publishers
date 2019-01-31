import * as React from "react";

import locale from "../../../locale/en";
import { Header, Subheader } from "../../style";
import {
  OverviewButton,
  ButtonGroup,
  InactiveText,
  Input,
  PaymentTotal,
  Text,
  Wrapper
} from "./paymentOverviewStyle";

interface IPaymentOverviewProps {
  confirmationDate: string;
  paymentTotal: string;
  inactive: boolean;
  defaultCurrency: string;
}

export default class PaymentOverview extends React.Component<
  IPaymentOverviewProps
> {
  public static defaultProps = {
    confirmationDate: "Jan 31, 2018",
    defaultCurrency: "BAT",
    inactive: false,
    paymentTotal: "999.9"
  };

  public uploadFile = file => {
    console.log(file);
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
            <label>
              <OverviewButton inactive={this.props.inactive}>
                {locale.payments.overview.uploadInvoice}
              </OverviewButton>
              <input type="file" id="upload" style={{ display: "none" }} />
            </label>
            <label>
              <OverviewButton inactive={this.props.inactive}>
                {locale.payments.overview.uploadReport}
              </OverviewButton>
              <Input type="file" id="upload" onChange={this.uploadFile} />
            </label>
          </ButtonGroup>
        </section>
      </Wrapper>
    );
  }
}
