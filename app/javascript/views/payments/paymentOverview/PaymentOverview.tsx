import * as React from "react";

import locale from "../../../locale/en";
import { Header, Subheader } from "../../style";
import { Button, ButtonGroup, Text, Wrapper } from "./style";

export default class PaymentOverview extends React.Component {
  public render() {
    return (
      <Wrapper>
        <section>
          <Header>{locale.payments.overview.nextPaymentDate}</Header>
          <Text>Feb 8th, 2019</Text>
        </section>

        <section>
          <Header>{locale.payments.overview.paymentTotal}</Header>
          <Text>999.9</Text> <Subheader>BAT</Subheader>
          <ButtonGroup>
            <Button>{locale.payments.overview.uploadInvoice}</Button>
            <Button>{locale.payments.overview.uploadReport}</Button>
          </ButtonGroup>
        </section>
      </Wrapper>
    );
  }
}
