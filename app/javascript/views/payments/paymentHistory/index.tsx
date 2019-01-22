import * as React from "react";

import locale from "../../../locale/en";
import { Header, Subheader } from "../../style";

export default class PaymentHistory extends React.Component {
  public render() {
    return (
      <Card>
        <Header>{locale.payments.history.title}</Header>
      </Card>
    );
  }
}
