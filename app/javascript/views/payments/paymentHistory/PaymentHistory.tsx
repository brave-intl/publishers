import * as React from "react";

import locale from "../../../locale/en";
import { IInvoice } from "../../payments/Payments";

import { FlexWrapper, Header, LoadingIcon } from "./PaymentHistoryStyle";

import InvoicesList from "./invoiceList/InvoiceList";

interface IInvoicesProps {
  invoices?: IInvoice[];
  isLoading: boolean;
  reloadTable: any;
}

export default class Invoices extends React.Component<IInvoicesProps> {
  public render() {
    return (
      <React.Fragment>
        <FlexWrapper>
          <Header>{locale.payments.history.title}</Header>
          <LoadingIcon isLoading={this.props.isLoading} />
        </FlexWrapper>
        <InvoicesList
          reload={this.props.reloadTable}
          invoices={this.props.invoices && this.props.invoices.slice(1)}
        />
      </React.Fragment>
    );
  }
}
