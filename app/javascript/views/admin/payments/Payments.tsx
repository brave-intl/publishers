import * as React from "react";

import { Cell, Container, Grid } from "../../../components/grid/Grid";
import UserNavbar from "../components/userNavbar/UserNavbar";
import { templateAreas, templateRows } from "./PaymentsStyle";

import CurrentChart from "./components/currentChart/CurrentChart";
import CurrentTable from "./components/currentTable/CurrentTable";
import EarningsChart from "./components/earningsChart/EarningsChart";
import TotalTable from "./components/totalTable/TotalTable";

interface IPaymentsState {
  data: any;
}

export enum NavbarSelection {
  Dashboard,
  Channels,
  Referrals,
  Payments
}

export default class Payments extends React.Component<{}, IPaymentsState> {
  constructor(props) {
    super(props);
    this.state = {
      data: { referralCodes: [{ stats: null }] }
    };
  }

  public componentDidMount() {
    this.fetchData();
  }

  public async fetchData() {
    const id = window.location.pathname.substring(
      window.location.pathname.lastIndexOf("/") + 1
    );
    const url = "/admin/payments/" + id;
    const options = {
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      },
      method: "GET"
    };
    const response = await fetch(url, options);
    const data = await response.json();
    this.setState({
      data
    });
  }

  public render() {
    return (
      <React.Fragment>
        <UserNavbar
          navbarSelection={NavbarSelection.Payments}
          name={this.state.data.name}
          userID={this.state.data.userID}
          status={this.state.data.status}
        />
        <Container>
          <Grid
            templateAreas={templateAreas}
            templateRows={templateRows}
            style={{ marginTop: "30px", marginBottom: "30px" }}
          >
            <Cell gridArea={"a"}>
              <CurrentChart
                referralBalance={this.state.data.currentReferralBalance}
                contributionBalance={this.state.data.currentContributionBalance}
              />
            </Cell>
            <Cell gridArea={"b"}>
              <EarningsChart transactions={this.state.data.transactions} />
            </Cell>
            <Cell gridArea={"c"}>
              <TotalTable
                downloads={this.state.data.downloads}
                installs={this.state.data.installs}
                confirmations={this.state.data.confirmations}
                channelBalances={this.state.data.currentChannelBalances}
                transactions={this.state.data.transactions}
              />
            </Cell>
            <Cell gridArea={"d"}>
              <CurrentTable
                referralBalance={this.state.data.currentReferralBalance}
                contributionBalance={this.state.data.currentContributionBalance}
                channelBalances={this.state.data.currentChannelBalances}
                totalBalance={this.state.data.currentOverallBalance}
              />
            </Cell>
          </Grid>
        </Container>
      </React.Fragment>
    );
  }
}
