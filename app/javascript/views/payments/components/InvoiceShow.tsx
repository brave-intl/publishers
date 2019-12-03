import * as React from "react";

import locale from "../../../locale/en";
import routes from "../../routes";

import { IInvoice, IInvoiceFile } from "../Payments";

import {
  Button,
  Card,
  Cell,
  Container,
  FormControl,
  Header,
  Subheader,
  Table,
  TableHeader,
  Wrapper
} from "../../style";
import { FlexWrapper, Link, SpacedHeader, Title } from "./InvoiceShowStyle";

import EditIconInput from "./editIconInput/EditIconInput";
import TrashOIcon from "./TrashOIcon/TrashOIcon";
import UploadDialog from "./uploadDialog/UploadDialog";

interface IInvoiceShowProps {
  invoice: IInvoice;
}

interface InvoiceShowState {
  invoice: IInvoice;
  invoiceFiles: IInvoiceFile[];
  isLoading: boolean;
  errorText: string;
  showArchived: boolean;
}

export default class InvoiceShow extends React.Component<
  IInvoiceShowProps,
  InvoiceShowState
> {
  public readonly state: InvoiceShowState = {
    errorText: "",
    invoice: this.props.invoice,
    invoiceFiles: this.props.invoice.files || [],
    isLoading: false,
    showArchived: false
  };

  constructor(props) {
    super(props);
    this.archiveOrRestore = this.archiveOrRestore.bind(this);
    this.saveInvoice = this.saveInvoice.bind(this);
  }

  public setLoading = isLoading => {
    this.setState({ isLoading });
  };

  public reloadInvoiceFiles = json => {
    this.setLoading(true);
    this.setState({ invoiceFiles: json.files });
    this.setLoading(false);
  };

  public archiveItem = e => {
    e.preventDefault();
    this.archiveOrRestore(e.target.getAttribute("href"), "DELETE");
  };

  public async archiveOrRestore(url, method) {
    const result = await fetch(url, {
      headers: {
        Accept: "text/html",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method
    });

    if (result.ok) {
      this.reloadInvoiceFiles(await result.json());
    } else {
      if (result.status === 500) {
        this.setState({
          errorText: locale.common.unexpectedError
        });
      } else {
        this.setState({ errorText: result.body.toString() });
      }
    }
  }

  public async saveInvoice(amount) {
    return new Promise((resolve, reject) => {
      const request = fetch(this.state.invoice.url, {
        body: `amount=${amount}`,
        headers: {
          Accept: "text/html",
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": document.head
            .querySelector("[name=csrf-token]")
            .getAttribute("content"),
          "X-Requested-With": "XMLHttpRequest"
        },
        method: "PATCH"
      });

      request.then(response => {
        if (response.status >= 200 && response.status < 300) {
          resolve(true);
        } else {
          reject();
        }
      });
    });
  }

  public render() {
    let completeForm;

    if (this.state.invoice.status !== "Pending") {
      completeForm = (
        <React.Fragment>
          <FormControl>
            <Header>{locale.payments.invoices.show.finalizedAmount}</Header>
            <div>{this.state.invoice.finalizedAmount || "--"}</div>
          </FormControl>

          <FormControl>
            <Header>{locale.payments.invoices.show.paymentDate}</Header>
            <div>{this.state.invoice.paymentDate || "--"}</div>
          </FormControl>
          <FormControl>
            <Header>{locale.payments.invoices.show.status}</Header>
            <div>{this.state.invoice.status || ""}</div>
          </FormControl>
        </React.Fragment>
      );
    }

    return (
      <div>
        <FormControl>
          <Title>
            {this.state.invoice.date}{" "}
            {locale.payments.invoices.show.description}
          </Title>
        </FormControl>

        <FormControl>
          <Header>{locale.payments.invoices.show.amount}</Header>
          <div>
            <EditIconInput
              initialValue={this.state.invoice.amount || ""}
              disabled={this.state.invoice.status !== "Pending"}
              onSave={this.saveInvoice}
            />
          </div>
        </FormControl>

        {completeForm}

        <FlexWrapper>
          <SpacedHeader>
            {locale.payments.invoices.show.files.title}
          </SpacedHeader>
          {this.state.invoice.status === "Pending" && (
            <UploadDialog
              route={routes.payments.invoices.show.invoice_files.path.replace(
                "{id}",
                this.state.invoice.id
              )}
              text={locale.payments.invoices.upload.button}
              afterSave={this.reloadInvoiceFiles}
              setLoading={this.setLoading}
            />
          )}
        </FlexWrapper>
        <Table>
          <thead>
            <tr>
              <TableHeader>
                {locale.payments.invoices.show.files.name}
              </TableHeader>
              <TableHeader>
                {locale.payments.invoices.show.files.time}
              </TableHeader>
              <TableHeader>
                {locale.payments.invoices.show.files.uploadedBy}
              </TableHeader>
              <TableHeader />
            </tr>
          </thead>
          <tbody>
            {this.state.invoiceFiles.map(invoiceFile => (
              <tr key={invoiceFile.id}>
                <Cell>
                  <a href={invoiceFile.file.url}>{invoiceFile.file.name}</a>
                </Cell>
                <Cell>{invoiceFile.createdAt}</Cell>
                <Cell>{invoiceFile.uploadedBy}</Cell>
                <Cell>
                  {invoiceFile.canArchive && (
                    <Link href={invoiceFile.url} onClick={this.archiveItem}>
                      <TrashOIcon style={{ width: "18" }} /> Archive
                    </Link>
                  )}
                </Cell>
              </tr>
            ))}
          </tbody>
        </Table>
      </div>
    );
  }
}
