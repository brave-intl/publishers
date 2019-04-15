import * as React from "react";

import Select from "brave-ui/components/formControls/select";
import Chart from "chart.js";
import Card from "../../../components/card/Card";

import UserNavbar from "../components/userNavbar/UserNavbar";

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

  public componentDidUpdate() {}

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
          <UserNavbar />
        </div>
        <div style={{ gridColumn: "1 / 7" }}>
          <Card>CURRENT</Card>
        </div>
        <div style={{ gridColumn: "7 / 13" }}>
          <Card>TO DATE</Card>
        </div>
      </div>
    );
  }
}
