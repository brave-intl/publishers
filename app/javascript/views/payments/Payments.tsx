import * as React from "react";

import { Container, Wrapper } from "../style";
import { Card, Layout, Row } from "./PaymentsStyle";

import { Navbar, NavbarSelection } from "../../components/navbar/Navbar";
import PaymentHistory from "./paymentHistory/PaymentHistory";
import PaymentOverview from "./paymentOverview/PaymentOverview";
import PaymentHeader from "./paymentsHeader/PaymentsHeader";
import UpholdCard from "./upholdCard/UpholdCard";

import routes from "../routes";

export interface IInvoice {
  id: string;
  date: string;
  url: string;
  finalizedAmount: string;
  files: IInvoiceFile[];
  amount: string;
  status: string;
  paid: boolean;
  paymentDate: string;
  createdAt: string;
}
export interface IInvoiceFile {
  id: string;
  canArchive: boolean;
  file: {
    name: string;
    url: string;
  };
  url: string;
  archived: boolean;
  uploadedBy: string;
  createdAt: string;
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
        <Navbar navbarSelection={NavbarSelection.Payments} />
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
              {/* <Card>
                <UpholdCard name="AliceBlogette" />
              </Card> */}
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
