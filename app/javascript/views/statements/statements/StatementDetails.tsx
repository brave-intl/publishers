import * as React from "react";

import { LoaderIcon } from "brave-ui/components/icons";

import locale from "../../../locale/en";
import { IStatementOverview } from "../Statements";

import { TableHeader } from "../StatementsStyle";
import {
  Amount,
  ChannelDescription,
  ChannelHeader,
  Date,
  Details,
  HideOverflow,
  Table,
  TableCell
} from "./StatementDetailsStyle";

import routes from "../../routes";

interface IStatementProps {
  statement: IStatementOverview;
  showPage?: boolean;
}

export default class StatementDetails extends React.Component<
  IStatementProps,
  any
> {
  constructor(props) {
    super(props);

    this.state = { rateCardStatement: [] };
  }

  public componentDidMount() {
    if (this.props.statement.showRateCards) {
      this.setState({ isLoading: true });
      this.loadGroups();
    }
  }

  public async loadGroups() {
    await fetch(
      routes.publishers.statements.rate_card.path +
        `?earning_period=${this.props.statement.earning_period}`,
      {
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.head
            .querySelector("[name=csrf-token]")
            .getAttribute("content"),
          "X-Requested-With": "XMLHttpRequest"
        },
        method: "GET"
      }
    )
      .then(response => {
        response.json().then(json => {
          this.setState({
            isLoading: false,
            rateCardStatement: json.rateCardStatement,
          });
        });
      })
  }

  public render() {
    return (
      <Details>
        <div className="mx-5 ">
          <div className="d-flex align-items-center justify-content-between">
            <div>
              <h6 className="m-0">
                <span>{locale.statements.overview.brand} </span>
                <span className="text-muted font-weight-light ml-1">
                  {locale.statements.overview.statement}
                </span>
              </h6>
            </div>
            <Date>{this.props.statement.earning_period}</Date>
          </div>

          <div className="mb-4 mt-3">
            {this.props.statement.name}

            <span className="mx-2 text-muted font-weight-light">|</span>
            <span className="text-muted">{this.props.statement.email}</span>
          </div>

          <div className="d-flex justify-content-between mb-3">
            <div>
              <div>{locale.statements.overview.amountDeposited}</div>
              <div>
                <Amount>
                  {parseFloat(this.props.statement.deposited).toFixed(2)}{" "}
                  <small>{this.props.statement.currency}</small>
                </Amount>
              </div>
            </div>

            <table className="table ml-4 border-bottom">
              <tbody>
                <tr>
                  <td>
                    <strong>{locale.statements.overview.totalEarned}</strong>
                  </td>
                  <td>
                    {Number.parseFloat(
                      this.props.statement.totalEarned
                    ).toFixed(2)}{" "}
                    {locale.bat}
                  </td>
                </tr>
                <tr>
                  <td>
                    <strong>
                      {locale.statements.overview.details.totalFees}
                    </strong>
                  </td>
                  <td>
                    {Number.parseFloat(this.props.statement.totalFees).toFixed(
                      2
                    )}{" "}
                    {locale.bat}
                  </td>
                </tr>
                <tr>
                  <td>
                    <strong>{locale.statements.overview.totalDeposited}</strong>
                  </td>
                  <td>
                    {Number.parseFloat(
                      this.props.statement.totalBATDeposited
                    ).toFixed(2)}{" "}
                    {locale.bat}
                  </td>
                </tr>
                <tr>
                  <td>
                    <strong>{locale.statements.overview.depositDate}</strong>
                  </td>
                  <td>{this.props.statement.payment_date}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div className="">
          <h5 className="px-5 mb-3">
            {locale.statements.overview.totalEarned}
            <span className="text-muted ml-2 font-weight-light">
              {locale.statements.overview.details.summary}
            </span>
          </h5>

          {this.props.statement.details.map((detail, index) => (
            <StatementDetail detail={detail} index={index} />
          ))}
        </div>

        <div className="mt-3 mx-5">
          <h5 className="mb-3">
            {locale.statements.overview.referrals}
            <span className="text-muted ml-2 font-weight-light">
              {locale.statements.overview.breakdown}
            </span>
          </h5>
          <p>
            {locale.statements.overview.referralsInfo}
          </p>

          <div className="">
            {this.state.isLoading && (
              <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />
            )}

            {!this.state.isLoading && this.props.statement.showRateCards && (
              <RateCardStatements
                rateCardStatement={this.state.rateCardStatement}
              />
            )}
          </div>
        </div>

        {!this.props.showPage && (
          <div className="px-5 py-3">
            <a
              data-piwik-action="StatementViewMore"
              data-piwik-name="Clicked"
              data-piwik-value=""
              href={routes.publishers.statements.show.path.replace(
                "{period}",
                this.props.statement.earning_period
              )}
            >
              {locale.statements.overview.viewMore}
            </a>
          </div>
        )}
      </Details>
    );
  }
}

interface IRateCardStatement {
  referral_code: string;
  details: Array<{
    group: {
      id: string;
      name: string;
      amount: string;
      currency: string;
      count: number;
    };
    confirmations: number;
    average_paid_per_confirmation: number;
    total_bat: number;
  }>;
}

const RateCardStatements = props => (
  <Table className="table">
    <thead>
      <tr>
        <TableHeader>Referral Code</TableHeader>
        <TableHeader>Region</TableHeader>
        <TableHeader>Confirmations</TableHeader>
        <TableHeader>Avg. / Confirmation</TableHeader>
        <TableHeader>Total</TableHeader>
      </tr>
    </thead>
    <tbody>
      {props.rateCardStatement.map((rateCardStatement: IRateCardStatement) =>
        rateCardStatement.details.map((detail, index) => (
          <tr key={detail.group.id}>
            <TableCell>
              {index === 0 && rateCardStatement.referral_code}
            </TableCell>
            <TableCell>{detail.group.name}</TableCell>
            <TableCell>{detail.confirmations}</TableCell>
            <TableCell>
              {detail.average_paid_per_confirmation.toFixed(2)} BAT
            </TableCell>
            <TableCell>{detail.total_bat.toFixed(2)} BAT</TableCell>
          </tr>
        ))
      )}
    </tbody>
  </Table>
);

const StatementDetail = props => (
  <div
    style={{
      background: props.index % 2 === 0 ? "#F3F3F6" : "",
      borderRadius: "6px"
    }}
    className="px-5 py-4"
  >
    <div className="">
      <ChannelHeader>{props.detail.title}</ChannelHeader>
      <ChannelDescription>{props.detail.description}</ChannelDescription>
    </div>
    <Table className="table m-0">
      <thead>
        <tr>
          <TableHeader>
            <strong className="text-uppercase">
              {locale.statements.overview.details.description}
            </strong>
          </TableHeader>
          <TableHeader className="text-right">
            <strong className="text-uppercase">
              {locale.statements.overview.details.amount}
            </strong>
          </TableHeader>
        </tr>
      </thead>
      <tbody>
        {props.detail.transactions.map(transaction => (
          <tr key={`${transaction.amount} ${Math.random()}`}>
            <TableCell>
              <HideOverflow>{transaction.channel}</HideOverflow>
            </TableCell>
            <TableCell className="text-right">
              {transaction.amount} {locale.bat}
            </TableCell>
          </tr>
        ))}
        <tr>
          <td>
            <strong>
              {props.detail.type === "fees" &&
                locale.statements.overview.details.totalFees}
              {props.detail.type !== "fees" &&
                locale.statements.overview.details.total}
            </strong>
          </td>
          <td className="text-right">
            <strong>
              {props.detail.amount} {locale.bat}
            </strong>
          </td>
        </tr>
      </tbody>
    </Table>
  </div>
);
