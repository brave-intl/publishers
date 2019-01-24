import * as React from "react";

import locale from "../../../locale/en";
import downloadIcon from "./downloadIcon.png";

import { Header, Subheader } from "../../style";
import { Cell, Link, Table, TableHeader } from "./style";

export default class PaymentHistory extends React.Component {
  public render() {
    return (
      <div>
        <Header>{locale.payments.history.title}</Header>

        <Table>
          <thead>
            <tr>
              <TableHeader>{locale.payments.history.earningPeriod}</TableHeader>
              <TableHeader>{locale.payments.history.paymentDate}</TableHeader>
              <TableHeader>
                {locale.payments.history.depositAccount}
              </TableHeader>
              <TableHeader>
                {locale.payments.history.confirmedEarning}
              </TableHeader>
              <TableHeader>
                {locale.payments.history.totalDeposited}
              </TableHeader>
              <TableHeader>{locale.payments.history.statement}</TableHeader>
            </tr>
          </thead>
          <tbody>
            <tr>
              <Cell>Nov 1- Nov 30, 2018</Cell>
              <Cell>Dec 8th, 2018</Cell>
              <Cell>Uphold @ aliceblogette</Cell>
              <Cell>99999.9</Cell>
              <Cell>999.9 EURO</Cell>
              <Cell>
                <Link href="#">View</Link>
                <Link href="#">
                  <img
                    src={downloadIcon}
                    style={{ marginRight: "5px" }}
                    width={22}
                    height={19}
                  />
                  Download
                </Link>
              </Cell>
            </tr>
          </tbody>
        </Table>
      </div>
    );
  }
}
