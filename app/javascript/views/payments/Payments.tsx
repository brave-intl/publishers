import * as React from "react";

import { Container, Wrapper } from "../style";
import { Card, Layout, Row } from "./PaymentsStyle";

import PaymentHistory from "./paymentHistory/PaymentHistory";
import PaymentOverview from "./paymentOverview/PaymentOverview";
import PaymentHeader from "./paymentsHeader/PaymentsHeader";
import UpholdCard from "./upholdCard/UpholdCard";

import routes from "../routes";

export interface IInvoice {
  id: string;
  date: string;
  url: string;
  finalized_amount: string;
  files: IInvoiceFile[];
  amount: string;
  status: string;
  paid: boolean;
  payment_date: string;
  created_at: string;
}
export interface IInvoiceFile {
  id: string;
  can_archive: boolean;
  file: {
    name: string;
    url: string;
  };
  url: string;
  archived: boolean;
  uploaded_by: string;
  created_at: string;
}
interface IPaymentsState {
  invoices: IInvoice[];
  isLoading: boolean;
}

export default class Payments extends React.Component<any, IPaymentsState> {
  public readonly state: IPaymentsState = {
    invoices: undefined,
    isLoading: false
  };

  constructor(props) {
    super(props);

    this.reloadTable = this.reloadTable.bind(this);
  }

  public componentDidMount() {
    if (this.state.invoices === undefined) {
      this.reloadTable();
    }
  }

  public async reloadTable() {
    this.setState({ isLoading: true });
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

    this.setState({ isLoading: false });
  }

  public render() {
    return (
      <Wrapper>
        <PaymentHeader />
        <Container>
          <Layout>
            <Row>
              <Card>
                <PaymentOverview
                  invoices={this.state.invoices}
                  inactive={
                    this.state.invoices === undefined ||
                    this.state.invoices[0] === undefined
                  }
                  reloadInvoices={this.reloadTable}
                />
              </Card>
              <Card>
                <UpholdCard name="AliceBlogette" />
              </Card>
            </Row>
            <Card>
              <PaymentHistory
                invoices={this.state.invoices}
                isLoading={this.state.isLoading}
                reloadTable={this.reloadTable}
              />
            </Card>
          </Layout>
        </Container>
      </Wrapper>
    );
  }
}
