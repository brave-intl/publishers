import { DownloadIcon } from "brave-ui/components/icons";
import * as moment from "moment";
import * as React from "react";

import locale from "../../../../locale/en";

import Modal, { ModalSize } from "../../../../components/modal/Modal";
import InvoiceShow from "../../components/InvoiceShow";
import { IInvoice } from "../../Payments";

import { Cell, Table, TableHeader } from "../../../style";
import { Link, NoResults } from "./InvoiceListStyle";

interface IInvoiceListProps {
  invoices: IInvoice[];
  reload: any;
}
interface IInvoiceListState {
  showModal: boolean;
  selectedInvoice?: IInvoice;
}

export default class InvoicesList extends React.Component<IInvoiceListProps> {
  public readonly state: IInvoiceListState = {
    showModal: false
  };

  public triggerModal = e => {
    e.preventDefault();

    const invoice = this.props.invoices.find(
      i => i.id === e.target.getAttribute("data-id")
    );

    if (!invoice || this.state.showModal) {
      this.props.reload();
    }

    this.setState({
      selectedInvoice: invoice,
      showModal: !this.state.showModal
    });
  };

  public render() {
    let noResults;
    let modal;

    if (this.props.invoices === undefined || this.props.invoices.length === 0) {
      noResults = <NoResults>{locale.payments.invoices.noResults}</NoResults>;
    }

    if (this.state.showModal) {
      modal = (
        <Modal
          show={this.state.showModal}
          size={ModalSize.Small}
          handleClose={this.triggerModal}
        >
          <InvoiceShow invoice={this.state.selectedInvoice} />
        </Modal>
      );
    }

    return (
      <div>
        <Table>
          <thead>
            <tr>
              <TableHeader>{locale.payments.invoices.period}</TableHeader>
              <TableHeader>{locale.payments.invoices.paymentDate}</TableHeader>
              <TableHeader>{locale.payments.invoices.amount}</TableHeader>
              <TableHeader>{locale.payments.invoices.status}</TableHeader>
              <TableHeader>
                {locale.payments.history.totalDeposited}
              </TableHeader>
              <TableHeader>
                {locale.payments.invoices.invoice_count}
              </TableHeader>
              <TableHeader>{locale.payments.history.statement}</TableHeader>
            </tr>
          </thead>
          <tbody>
            {modal}
            {this.props.invoices &&
              this.props.invoices.map(invoice => (
                <tr key={invoice.id}>
                  <Cell>{invoice.date}</Cell>
                  <Cell>{invoice.paymentDate || "--"}</Cell>
                  <Cell>{invoice.amount}</Cell>
                  <Cell>{invoice.status}</Cell>
                  <Cell>--</Cell>
                  <Cell>
                    <Link
                      href="#"
                      data-id={invoice.id}
                      onClick={this.triggerModal}
                    >
                      {this.pluralize(
                        invoice.files.length,
                        locale.payments.invoices.invoice_count
                      )}
                    </Link>
                  </Cell>
                  <Cell>
                    <Link href="#">View</Link>
                    <Link href="#">
                      <DownloadIcon style={{ width: "32px" }} />
                      Download
                    </Link>
                  </Cell>
                </tr>
              ))}
          </tbody>
        </Table>
        {noResults}
      </div>
    );
  }

  private pluralize = (count, text) => {
    if (count === 1) {
      return `${count} ${text.substring(0, text.length - 1)}`;
    } else if (count === 0) {
      return locale.payments.invoices.invoice_view;
    }
    return `${count} ${text}`;
  };
}
