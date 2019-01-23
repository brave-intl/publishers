import * as React from "react";

import locale from "../../../../locale/en";
import { NotConnected, Link, StatusIcon } from "./style";

export enum WalletStatus {
  ReauthorizationNeeded,
  Incomplete,
  Verified,
  AccessParametersAcquired,
  CodeAcquired,
  Unconnected
}
interface IUpholdStatusProps {
  status: WalletStatus;
}

export class UpholdStatus extends React.Component<IUpholdStatusProps> {
  public render() {
    let statusText = <span />;

    switch (this.props.status) {
      case WalletStatus.Verified: {
        statusText = (
          <React.Fragment>
            <span>{locale.payments.account.connected}</span>
            <Link href="">{locale.payments.account.disconnect}</Link>
          </React.Fragment>
        );
        break;
      }
      default: {
        statusText = (
          <React.Fragment>
            <NotConnected>{locale.payments.account.notConnected}</NotConnected>
            <Link href="">{locale.payments.account.connect}</Link>
          </React.Fragment>
        );
        break;
      }
    }

    return (
      <section>
        <StatusIcon active={this.props.status === WalletStatus.Verified} />
        {statusText}
      </section>
    );
  }
}
