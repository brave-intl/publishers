import * as React from "react";
import { FormattedMessage, FormattedNumber, injectIntl } from "react-intl";

import { TableHeader } from "../../StatementsStyle";
import {
  Amount,
  ChannelHeader,
  Date,
  Description,
  Details,
  HideOverflow,
  Table,
  TableCell,
  Total,
  TotalCell,
} from "../StatementDetailsStyle";


const DetailSection = (props) => (
  <div
    style={{
      background: props.index % 2 === 0 ? "#F3F3F6" : "",
      borderRadius: "6px",
    }}
    className="px-5 py-4"
  >
    <div className="">
      <ChannelHeader>{props.detail.title}</ChannelHeader>
      <Description>{props.detail.description}</Description>
    </div>
    <Table className="table m-0">
      <thead>
        <tr>
          <TableHeader>
            <strong className="text-uppercase">
              <FormattedMessage id="statements.overview.details.description" />
            </strong>
          </TableHeader>
          <TableHeader className="text-right">
            <strong className="text-uppercase">
              <FormattedMessage id="statements.overview.details.amount" />
            </strong>
          </TableHeader>
        </tr>
      </thead>
      <tbody>
        {props.detail.transactions.map((transaction) => (
          <tr key={`${transaction.amount} ${Math.random()}`}>
            <TableCell>
              <HideOverflow>
                {transaction.transactionType === "fees" && (
                  <FormattedMessage id="statements.overview.details.fee" />
                )}{" "}
                {transaction.channel}
              </HideOverflow>
            </TableCell>
            <TableCell className="text-right">
              <FormattedNumber
                value={transaction.amount}
                maximumFractionDigits={2}
              />{" "}
              <FormattedMessage id="bat" />
            </TableCell>
          </tr>
        ))}
        <tr>
          <td>
            <strong>
              <FormattedMessage id="statements.overview.details.total" />
            </strong>
          </td>
          <td className="text-right">
            <strong>
              <FormattedNumber
                value={props.detail.amount}
                maximumFractionDigits={2}
              />{" "}
              <FormattedMessage id="bat" />
            </strong>
          </td>
        </tr>
      </tbody>
    </Table>
  </div>
);

export default injectIntl(DetailSection);
