import * as React from "react";

import {
  Button,
  Card,
  Cell,
  Container,
  Table,
  TableHeader,
  Wrapper
} from "../style";

import PaymentsHeader from "../payments/header/Header";
import routes from "../routes";
import { FlexWrapper, Header, LoadingIcon } from "./InvoicesStyle";

import locale from "../../locale/en";
import UploadDialog from "./uploadDialog/UploadDialog";

interface IInvoice {
  id: string;
  filename: string;
  file_url: string;
  uploaded_by_user: string;
  created_at: string;
}
interface IInvoicesProps {
  invoices: IInvoice[];
}

interface IInvoicesState {
  showUpload: boolean;
  isLoading: boolean;
  invoices: IInvoice[];
}

export default class Invoices extends React.Component<
  IInvoicesProps,
  IInvoicesState
> {
  public readonly state: IInvoicesState = {
    invoices: this.props.invoices,
    isLoading: false,
    showUpload: false
  };
  constructor(props) {
    super(props);
    this.reloadTable = this.reloadTable.bind(this);
  }

  public setLoading = isLoading => {
    this.setState({ isLoading });
  };

  public async reloadTable() {
    this.setLoading(true);
    const result = await fetch(routes.payments.invoices.path, {
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.head
          .querySelector("[name=csrf-token]")
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    }).then(response => {
      response.json().then(json => {
        this.setState({ invoices: json.invoices });
      });
    });

    this.setLoading(false);
  }

  public render() {
    let noResults;

    if (this.state.invoices.length === 0) {
      noResults = (
        <tr>
          <td colSpan={5} align="center">
            {locale.payments.invoices.noResults}
          </td>
        </tr>
      );
    }

    return (
      <Wrapper>
        <PaymentsHeader />
        <Container>
          <Card>
            <FlexWrapper>
              <Header>{locale.payments.invoices.title}</Header>
              <UploadDialog
                route={routes.payments.invoices.path}
                text={locale.payments.invoices.upload}
                afterSave={this.reloadTable}
                setLoading={this.setLoading}
              />
              <LoadingIcon isLoading={this.state.isLoading} />
            </FlexWrapper>

            <Table>
              <thead>
                <tr>
                  <TableHeader>{locale.payments.invoices.fileName}</TableHeader>
                  <TableHeader>
                    {locale.payments.invoices.createdAt}
                  </TableHeader>
                  <TableHeader>
                    {locale.payments.invoices.uploadedBy}
                  </TableHeader>
                </tr>
              </thead>
              <tbody>
                {noResults}
                {this.state.invoices.map(report => (
                  <tr key={report.id}>
                    <Cell>
                      <a href={report.file_url}>{report.filename}</a>
                    </Cell>
                    <Cell>{report.created_at}</Cell>
                    <Cell>{report.uploaded_by_user}</Cell>
                  </tr>
                ))}
              </tbody>
            </Table>
          </Card>
        </Container>
      </Wrapper>
    );
  }
}
