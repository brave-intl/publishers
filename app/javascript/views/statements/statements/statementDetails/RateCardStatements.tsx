import * as React from "react";
import { FormattedMessage } from "react-intl";

import { LoaderIcon } from "brave-ui/components/icons";
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

const RateCardStatements = (props) => (
  <div className="mt-3 mx-5">
    <h5 className="mb-3">
      <FormattedMessage id="statements.overview.referrals" />
      <span className="text-muted ml-2 font-weight-light">
        <FormattedMessage id="statements.overview.breakdown" />
      </span>
    </h5>
    <p>
      <FormattedMessage id="statements.overview.referralsInfo" />
    </p>

    <div className="">
      {props.isLoading && (
        <LoaderIcon style={{ width: "36px", margin: "0 auto" }} />
      )}
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
          {props.rateCardStatement.map(
            (rateCardStatement: IRateCardStatement) =>
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
    </div>
  </div>
);

export default RateCardStatements;
