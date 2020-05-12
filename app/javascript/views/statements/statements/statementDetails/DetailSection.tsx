import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";

import { CurrencyNumber } from "../../Statements";
import { TableHeader } from "../../StatementsStyle";
import { SettlementDestinationLink } from "../StatementDetails";
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

const DetailSection = (props) => {
  let settlementDestination;
  const foundDestination = props.detail.transactions.find(
    (x) => x.settlementDestination
  );
  if (foundDestination) {
    settlementDestination = foundDestination.settlementDestination;
  }

  return (
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
                <CurrencyNumber value={transaction.amount} />{" "}
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
              <SettlementDestinationLink
                settlementDestination={settlementDestination}
              >
                <strong>
                  <CurrencyNumber value={props.detail.amount} />{" "}
                  <FormattedMessage id="bat" />
                </strong>
              </SettlementDestinationLink>
            </td>
          </tr>
        </tbody>
      </Table>
    </div>
  );
};

export default injectIntl(DetailSection);
