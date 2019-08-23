import * as React from "react";
import locale from "../../../locale/en";
import { IStatementOverview } from "../Statements";

import { TableHeader } from "../StatementsStyle";
import {
  Amount,
  ChannelHeader,
  Date,
  Details,
  Table,
  TableCell
} from "./StatementDetailsStyle";

interface IStatementProps {
  statement: IStatementOverview;
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
                  {this.props.statement.deposited}{" "}
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
                    {this.props.statement.amount} {locale.bat}
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

        <div className="mb-3">
          <h5 className="px-5 mb-3">
            {locale.statements.overview.totalEarned}
            <span className="text-muted ml-2 font-weight-light">
              {locale.statements.overview.details.title}
            </span>
          </h5>
          {this.props.statement.details.map((detail, index) => (
            <StatementChannel detail={detail} index={index} />
          ))}
        </div>
      </Details>
    );
  }
}

const StatementChannel = props => (
  <div
    style={{ background: props.index % 2 === 0 ? "#F3F3F6" : "" }}
    className="px-5 py-4"
  >
    <div className="d-flex justify-content-between">
      <ChannelHeader>{props.detail.channel}</ChannelHeader>
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
            <TableCell>{transaction.transaction_type}</TableCell>
            <TableCell className="text-right">
              {transaction.amount} {locale.bat}
            </TableCell>
          </tr>
        ))}
        <tr>
          <td>
            <strong>{locale.statements.overview.details.total}</strong>
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
