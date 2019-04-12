import * as React from "react";

import Select from "brave-ui/components/formControls/select";
import Chart from "chart.js";
import Card from "../../../components/card/Card";

import ReferralsHeader from "./components/referralsHeader/ReferralsHeader";

import { element } from "prop-types";
import console = require("console");

export default class Referrals extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {
      data: { referralCodes: [{stats: null}] }
    };
  }

  public componentDidMount() {
    this.fetchData();
  }

  public componentDidUpdate() {
    this.createReferralsChart(this.state.data.referralCodes[0]);
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

  public handleSelect = e => {
    this.createReferralsChart(this.state.data.referralCodes[e]);
  }

  public createReferralsChart(referralCode) {

    let stats = JSON.parse(referralCode.stats)

    const node = this.node;

    let referralChartDatasets = []

    let referralChartLabels = []
    let downloads = []
    let installs = []
    let confirmations = []
    stats.forEach((stat) => {
      referralChartLabels.push(stat.ymd)
      downloads.push(stat.retrievals)
      installs.push(stat.first_runs)
      confirmations.push(stat.finalized)
    })

    let referralChartData = {
      labels: referralChartLabels,
      datasets: [
        {
          label: "Downloads",
          data: downloads,
          borderColor: "#FFCD56",
          backgroundColor: "#FFCD56",
          fill: true
        }, 
        {
          label: "Installs",
          data: installs,
          borderColor: "#36A2EB",
          backgroundColor: "#36A2EB",
          fill: true
        }, 
        {
          label: "Confirmations",
          data: confirmations,
          borderColor: "#FF6384",
          backgroundColor: "#FF6384",
          fill: true
        }]
    }

    let referralChartSettings = {
      options: {
        scales: {
          yAxes: [
            {
              display: false,
              stacked: true
            }
          ]
        }
      },
      type: "line"
      data: referralChartData  
    }

    var myChart = new Chart(node, referralChartSettings)
  }

  public render() {
    return (
      <div
        style={{
          margin: "30px",
          display: "grid",
          gridTemplateColumns:
            "1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr",
          gridGap: "30px"
        }}
      >
        <div style={{ gridColumn: "1 / 13" }}>
          <ReferralsHeader
            downloads={this.state.data.downloads}
            installs={this.state.data.installs}
            confirmations={this.state.data.confirmations}
          />
        </div>
        <div style={{ gridColumn: "1 / 4" }}>
          <Card>
            <Select onChange={e => this.handleSelect(e)}>
            {this.populateSelect()}
            </Select>
          </Card>
        </div>
        <div style={{ gridColumn: "4 / 13" }}>
          <Card>
            <canvas ref={node => (this.node = node)} />
          </Card>
        </div>
      </div>
    );
  }
}
