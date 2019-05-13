import * as React from "react";

import { Cell, Container, Grid } from "../../../components/grid/Grid";
import UserNavbar from "../components/userNavbar/UserNavbar";
import { templateAreas, templateRows } from "./PaymentsStyle";

import CurrentChart from "./components/currentChart/CurrentChart";
import CurrentTable from "./components/currentTable/CurrentTable";
import EarningsChart from "./components/earningsChart/EarningsChart";
import TotalTable from "./components/totalTable/TotalTable";

interface IPaymentsProps {
  data: any;
}

interface IPaymentsState {
  data: any;
}

export enum NavbarSelection {
  Dashboard,
  Channels,
  Referrals,
  Payments
}

export default class Payments extends React.Component<
  IPaymentsProps,
  IPaymentsState
> {
  constructor(props) {
    super(props);
  }

  public render() {
    return (
      <React.Fragment>
        <UserNavbar
          navbarSelection="Payments"
          publisher={this.props.data.publisher}
        />
        <Container>
          <Grid
            templateAreas={templateAreas}
            templateRows={templateRows}
            style={{ marginTop: "30px", marginBottom: "30px" }}
          >
            <Cell gridArea={"a"}>
              <CurrentChart
                referralBalance={this.props.data.current.referralBalance}
                contributionBalance={
                  this.props.data.current.contributionBalance
                }
              />
            </Cell>
            <Cell gridArea={"b"}>
              <EarningsChart
                transactions={this.props.data.historic.transactions}
              />
            </Cell>
            <Cell gridArea={"c"}>
              <TotalTable
                downloads={this.props.data.historic.downloads}
                installs={this.props.data.historic.installs}
                confirmations={this.props.data.historic.confirmations}
                channelBalances={this.props.data.current.channelBalances}
                transactions={this.props.data.historic.transactions}
              />
            </Cell>
            <Cell gridArea={"d"}>
              <CurrentTable
                referralBalance={this.props.data.current.referralBalance}
                contributionBalance={
                  this.props.data.current.contributionBalance
                }
                channelBalances={this.props.data.current.channelBalances}
                totalBalance={this.props.data.current.overallBalance}
                currentDownloads={this.props.data.current.downloads}
                currentInstalls={this.props.data.current.installs}
                currentConfirmations={this.props.data.current.confirmations}
              />
            </Cell>
          </Grid>
        </Container>
      </React.Fragment>
    );
  }
}
