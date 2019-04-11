import * as React from "react";

import Select from "brave-ui/components/formControls/select";
import Chart from "chart.js";
import Card from "../../../components/card/Card";

import ReferralsHeader from "./components/referralsHeader/ReferralsHeader";

import { element } from "prop-types";

export default class Referrals extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {
      data: { referralCodes: [] }
    };
  }

  public componentDidMount() {
    this.fetchData();

    const node = this.node;

    var myChart = new Chart(node, {
      type: "line",
      data: [{ x: 12, y: 20 }, { x: 20, y: 25 }]
    });
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
            <Select>{this.populateSelect()}</Select>
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
