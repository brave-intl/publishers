import * as React from "react";

import { DownloadIcon } from "brave-ui/components/icons";

import Modal, { ModalSize } from "../../components/modal/Modal";
import locale from "../../locale/en";
import EmptyStatement from "./statements/EmptyStatement";
import StatementDetails from "./statements/StatementDetails";
import { Header, LoadingIcon, TableHeader } from "./StatementsStyle";

import routes from "../routes";

interface IStatementsState {
  isLoading: boolean;
  statements: IStatementOverview[];
}

export interface IStatementOverview {
  name: string;
  email: string;
  earning_period: string;
  payment_date: string;
  destination: string;
  deposited: string;
  currency: string;
  details: any;
  isOpen: boolean;
  totalFees: string;
  totalEarned: string;
  totalBATDeposited: string;
  rawTransactions: any;
}

export default class Statements extends React.Component<any, IStatementsState> {
  public readonly state: IStatementsState = {
    isLoading: true,
    statements: undefined
  };

  constructor(props) {
    super(props);
  }

  public componentDidMount() {
    if (this.state.statements === undefined) {
      this.reloadTable();
    }
  }

  public async reloadTable() {
    this.setState({ isLoading: true });
    const id = `?id=${this.props.publisher_id}` || "";

    const result = await fetch(routes.publishers.statements.index.path + id, {
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
        this.setState({ statements: json.overviews });
      });
    });

    this.setState({ isLoading: false });
  }

  public modalClick = period => {
    const newStatements = [...this.state.statements];

    const statement = newStatements.find(
      item => item.earning_period === period
    );

    if (statement) {
      statement.isOpen = !statement.isOpen;
    }

    this.setState({ statements: newStatements });
  };

  public render() {
    return (
      <div>
        <Header>{locale.statements.overview.title}</Header>
        <p>{locale.statements.overview.description}</p>
        <table className="table ">
          <thead>
            <tr>
              <TableHeader>
                {locale.statements.overview.earningPeriod}
              </TableHeader>
              <TableHeader>
                {locale.statements.overview.paymentDate}
              </TableHeader>
              <TableHeader>
                {locale.statements.overview.confirmedEarning}
              </TableHeader>
              <TableHeader>
                {locale.statements.overview.totalDeposited}
              </TableHeader>
              <TableHeader>{locale.statements.overview.statement}</TableHeader>
            </tr>
          </thead>
          <tbody>
            {!this.state.statements && (
              <tr>
                <td colSpan={5} align="center">
                  <LoadingIcon isLoading={this.state.isLoading} />
                </td>
              </tr>
            )}
            {this.state.statements &&
              this.state.statements.map(statement => (
                <tr key={statement.earning_period}>
                  <td>{statement.earning_period}</td>
                  <td>{statement.payment_date}</td>
                  <td>
                    {Number.parseFloat(statement.totalBATDeposited).toFixed(4)}{" "}
                    <small>{locale.bat}</small>
                  </td>
                  <td>
                    {Number.parseFloat(statement.deposited).toFixed(2)}{" "}
                    <small>{statement.currency}</small>
                  </td>
                  <td>
                    <div className="d-flex">
                      <a
                        onClick={() =>
                          this.modalClick(statement.earning_period)
                        }
                        href="#"
                        className="mr-4"
                      >
                        {locale.statements.overview.view}
                      </a>
                      {this.state.statements && (
                        <Modal
                          show={statement.isOpen}
                          size={ModalSize.Medium}
                          handleClose={() =>
                            this.modalClick(statement.earning_period)
                          }
                          padding={false}
                        >
                          <StatementDetails statement={statement} />
                        </Modal>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            {/* No results */}
            {this.state.statements && this.state.statements.length === 0 && (
              <tr>
                <td colSpan={5} align="center">
                  <EmptyStatement style={{ width: "100px", height: "71px" }} />
                  <div className="mt-1 text-muted">
                    {locale.statements.overview.noStatements}
                  </div>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    );
  }
}
