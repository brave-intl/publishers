import * as React from "react";

import Select from "brave-ui/components/formControls/select";
import Chart from "chart.js";
import Card from "../../../components/card/Card";
import { Cell, Container, Grid } from "../../../components/grid/Grid";

import UserNavbar from "../components/userNavbar/UserNavbar";
import CurrentTable from "./components/currentTable/CurrentTable";
import ReferralsChart from "./components/referralsChart/ReferralsChart";
import TotalTable from "./components/totalTable/TotalTable";

import { element } from "prop-types";

export default class Referrals extends React.Component<{}, {}> {
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
    const url = "/admin/referrals/" + id;
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

  public populateSelect() {
    return this.state.data.referralCodes.map((el, index) => (
      <div key={index} data-value={index}>
        {el.referral_code}
      </div>
    ));
  }

  public handleSelect = e => {};

  public render() {
    return (
      <Container>
        <Grid>
          <Cell startColumn={1} endColumn={13}>
            <UserNavbar />
          </Cell>
          <Cell startColumn={1} endColumn={5}>
            <TotalTable
              downloads={this.state.data.downloads}
              installs={this.state.data.installs}
              confirmations={this.state.data.confirmations}
            />
          </Cell>
          <Cell startColumn={5} endColumn={13}>
            <Card>Earnings Chart Coming Soon...</Card>
          </Cell>
          <Cell startColumn={1} endColumn={13}>
            <CurrentTable
              referralBalance={this.state.data.currentReferralBalance}
            />
          </Cell>
          <Cell startColumn={1} endColumn={4}>
            <Card>
              <Select onChange={e => this.handleSelect(e)}>
                {this.populateSelect()}
              </Select>
            </Card>
          </Cell>
          <Cell startColumn={4} endColumn={13}>
            <ReferralsChart referralCode={this.state.data.referralCodes[0]} />
          </Cell>
        </Grid>
      </Container>
    );
  }
}
