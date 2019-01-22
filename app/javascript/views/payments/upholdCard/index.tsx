import * as React from "react";

import { CaratRightIcon } from "brave-ui/components/icons";
import locale from "../../../locale/en";
import { Header, Subheader } from "../../style";
import { Card, Text } from "./style";
import { UpholdStatus, WalletStatus } from "./upholdStatus";

interface IUpholdCardProps {
  name: string;
  walletStatus: WalletStatus;
  lastDeposit: string;
  currency: string;
}
interface IUpholdCardState {
  isLoading: boolean; // like this
}

export default class UpholdCard extends React.Component<
  IUpholdCardProps,
  IUpholdCardState
> {
  public static defaultProps = {
    currency: "euro",
    lastDeposit: "999.99",
    walletStatus: WalletStatus.Unconnected
  };

  public render() {
    const caretRight = (
      <CaratRightIcon
        style={{
          color: "#00bcd6",
          cursor: "pointer",
          height: "25px",
          marginBottom: "3px",
          width: "25px"
        }}
      />
    );

    return (
      <Card>
        <section>
          <Header>{locale.payments.title}</Header>
          <div>{this.props.name}</div>
          <UpholdStatus status={this.props.walletStatus} />
        </section>

        <section>
          <Header>{locale.payments.lastDeposit}</Header>
          <div>
            <Text>{this.props.lastDeposit}</Text>
            <Subheader> {this.props.currency}</Subheader>
          </div>
        </section>

        <section>
          <div>
            <a href="#">
              {locale.payments.changeAccount}
              {caretRight}
            </a>
          </div>
          <div>
            <a href="#">
              {locale.payments.changeDepositCurrency}
              {caretRight}
            </a>
          </div>
          <div>
            <a href="#">
              {locale.payments.manageFunds}
              {caretRight}
            </a>
          </div>
        </section>
      </Card>
    );
  }
}
