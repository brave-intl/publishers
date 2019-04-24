import * as React from "react";

import Card from "../../../components/card/Card";
import { Cell, Container, Grid } from "../../../components/grid/Grid";
import UserNavbar from "../components/userNavbar/UserNavbar";
import {
  xsTemplate,
  smTemplate,
  mdTemplate,
  lgTemplate,
  xlTemplate,
  xsRows
} from "./PaymentsStyle";

import CurrentTable from "./components/currentTable/CurrentTable";
import TotalTable from "./components/totalTable/TotalTable";
import EarningsChart from "./components/earningsChart/EarningsChart";
import console = require("console");

export default class Payments extends React.Component<{}, {}> {
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
      <Container>
        <Grid
          xsTemplate={xsTemplate}
          smTemplate={smTemplate}
          mdTemplate={mdTemplate}
          lgTemplate={lgTemplate}
          xlTemplate={xlTemplate}
        >
          <Cell gridArea={"navbar"}>
            <UserNavbar />
          </Cell>
          <Cell gridArea={"total"}>
            <TotalTable
              downloads={this.state.data.downloads}
              installs={this.state.data.installs}
              confirmations={this.state.data.confirmations}
              channelBalances={this.state.data.currentChannelBalances}
            />
          </Cell>
          <Cell gridArea={"earnings"}>
            <EarningsChart transactions={this.state.data.transactions} />
          </Cell>
          <Cell gridArea={"current"}>
            <CurrentTable
              referralBalance={this.state.data.currentReferralBalance}
              contributionBalance={this.state.data.currentContributionBalance}
              channelBalances={this.state.data.currentChannelBalances}
              totalBalance={this.state.data.currentOverallBalance}
            />
          </Cell>
        </Grid>
      </Container>
    );
  }
}
