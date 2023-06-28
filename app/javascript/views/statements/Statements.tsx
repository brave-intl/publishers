import * as moment from "moment";
import * as React from "react";
import {
  FormattedMessage,
  FormattedNumber,
  injectIntl,
} from "react-intl";
import ReactTooltip from "react-tooltip";

import { DownloadIcon } from "brave-ui/components/icons";

import Modal, { ModalSize } from "../../components/modal/Modal";
import EmptyStatement from "./statements/EmptyStatement";
import StatementDetails from "./statements/StatementDetails";
import { Header, LoadingIcon, TableHeader } from "./StatementsStyle";

import routes from "../routes";

interface IStatementsState {
  isLoading: boolean;
  statements: IStatementOverview[];
}

export interface IStatementTotal {
  contributionSettlement: number;
  referralSettlement: number;
  fees: number;
  totalBraveSettled: number;
  upholdContributionSettlement: any;
}

interface IEarningPeriod {
  startDate: string;
  endDate: string;
}
export interface IStatementOverview {
  publisherId: string;
  name: string;
  email: string;
  earningPeriod: IEarningPeriod;
  paymentDate: string;
  destination: string;
  totalEarned: number;
  deposited: any; // { "USD" : number }
  depositedTypes: any;
  currency: string;
  details: any;
  isOpen: boolean;
  totals: IStatementTotal;
  batTotalDeposited: number;
  rawTransactions: any;
  showRateCards: boolean;
  settlementDestination: string;
}

export const DisplayEarningPeriod = (earningPeriod: IEarningPeriod) => {
  const date = "MMM Y";
  return (
    <React.Fragment>
      {moment(earningPeriod.startDate).format(date)}
      {" - "}
      {earningPeriod.endDate && moment(earningPeriod.endDate).format(date)}
    </React.Fragment>
  );
};

export const DisplayPaymentDate = (paymentDate: string) => {
  if (paymentDate) {
    return moment(paymentDate).format("MMM DD, YYYY");
  }
  return "--";
};

export const GetParameterCaseInsensitive = (object, key) => {
  return object[
    Object.keys(object).find((k) => k.toLowerCase() === key.toLowerCase())
  ];
};

export const DepositBreakdown = (props) => {
  const id = props.name + "-" + Math.random();
  return (
    <React.Fragment>
      <span data-tip data-for={id}>
        {props.children}
      </span>

      <ReactTooltip id={id}>
        <table className="table text-light m-0">
          <tbody>
            {Object.keys(props.results).map((type) => (
              <tr key={type}>
                <td className="border-0 text-right">
                  <FormattedMessage id={`statements.overview.types.${type}`} />
                  {":  "}
                </td>
                <td className="border-0 text-left">
                  <CurrencyNumber value={props.results[type]} /> {props.name}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </ReactTooltip>
    </React.Fragment>
  );
};

export const CurrencyNumber = (props) => (
  <FormattedNumber
    value={props.value}
    maximumFractionDigits={2}
    minimumFractionDigits={2}
  />
);

class Statements extends React.Component<any, IStatementsState> {
  public readonly state: IStatementsState = {
    isLoading: true,
    statements: undefined,
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
        "X-Requested-With": "XMLHttpRequest",
      },
      method: "GET",
    }).then((response) => {
      response.json().then((json) => {
        this.setState({ statements: json.overviews });
      });
    });

    this.setState({ isLoading: false });
  }

  public modalClick = (period) => {
    const newStatements = [...this.state.statements];

    const statement = newStatements.find(
      (item) => item.earningPeriod.startDate === period.startDate
    );

    if (statement) {
      statement.isOpen = !statement.isOpen;
    }

    this.setState({ statements: newStatements });
    return false;
  };

  public render() {
    return (
      <div>
        <Header>
          <FormattedMessage id="statements.overview.title" />
        </Header>
        <p>
          <FormattedMessage id="statements.overview.description" />
        </p>
        <table className="table statement-table">
          <thead>
            <tr>
              <TableHeader>
                <FormattedMessage id="statements.overview.earningPeriod" />
              </TableHeader>
              <TableHeader>
                <FormattedMessage id="statements.overview.paymentDate" />
              </TableHeader>
              <TableHeader className="text-right" style={{ minWidth: "150px" }}>
                <FormattedMessage id="statements.overview.totalBraveSettled" />
              </TableHeader>
              <TableHeader className="text-right" style={{ minWidth: "175px" }}>
                <FormattedMessage id="statements.overview.amountDeposited" />
              </TableHeader>
              <TableHeader className="text-right">
                <FormattedMessage id="statements.overview.statement" />
              </TableHeader>
            </tr>
          </thead>
          <tbody>
            {!this.state.statements && (
              <tr>
                <td colSpan={6}>
                {/*<td colSpan={6} align="center">*/}
                  <LoadingIcon isLoading={this.state.isLoading} />
                </td>
              </tr>
            )}
            {this.state.statements &&
              this.state.statements.map((statement) => (
                <tr key={statement.earningPeriod.startDate}>
                  <td>{DisplayEarningPeriod(statement.earningPeriod)}</td>
                  <td>{DisplayPaymentDate(statement.paymentDate)}</td>
                  <td className="text-right">
                    <CurrencyNumber
                      value={statement.totals.totalBraveSettled}
                    />
                    <small>
                      {" "}
                      <FormattedMessage id="bat" />
                    </small>
                  </td>
                  <td className="text-right">
                    {Object.keys(statement.deposited).map((name) => (
                      <DepositBreakdown
                        name={name}
                        key={name}
                        results={GetParameterCaseInsensitive(
                          statement.depositedTypes,
                          name
                        )}
                      >
                        <React.Fragment>
                          <CurrencyNumber
                            value={statement.deposited[name]}
                            maximumFractionDigits={2}
                          />{" "}
                          <small>{name}</small>
                          <br />
                        </React.Fragment>
                      </DepositBreakdown>
                    ))}
                  </td>
                  <td>
                    <div className="d-flex justify-content-end">
                      <a
                        onClick={(event) => {
                          event.preventDefault();
                          this.modalClick(statement.earningPeriod);
                        }}
                        href={routes.publishers.statements.show.path.replace(
                          "{period}",
                          statement.earningPeriod.startDate
                        )}
                        className="mr-4"
                      >
                        <FormattedMessage id="statements.overview.view" />
                      </a>
                      {this.state.statements && (
                        <Modal
                          show={statement.isOpen}
                          size={ModalSize.Medium}
                          handleClose={() =>
                            this.modalClick(statement.earningPeriod)
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
                <td colSpan={6}>
                {/*<td colSpan={6} align="center">*/}
                  <EmptyStatement style={{ width: "100px", height: "71px" }} />
                  <div className="mt-1 text-muted">
                    <FormattedMessage id="statements.overview.noStatements" />
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
export default injectIntl(Statements);
