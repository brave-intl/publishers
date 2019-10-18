import * as React from "react";
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
                    {Number.parseFloat(this.props.statement.totalEarned).toFixed(2)}{" "}
                    {locale.bat}
                  </td>
                </tr>
                <tr>
                  <td>
                    <strong>{locale.statements.overview.details.totalFees}</strong>
                  </td>
                  <td>
                    {Number.parseFloat(this.props.statement.totalFees).toFixed(2)}{" "}
                    {locale.bat}
                  </td>
                </tr>
                <tr>
                  <td>
                    <strong>{locale.statements.overview.totalDeposited}</strong>
                  </td>
                  <td>
                    {Number.parseFloat(this.props.statement.totalBATDeposited).toFixed(2)}{" "}
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
        {!this.props.showPage && (
          <div className="px-5 py-3">
            <a
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
          <tr key={transaction.amount}>
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
