import * as React from "react";
import * as ReactDOM from "react-dom";
import Select from "brave-ui/components/formControls/select";
import 'dashboard_chart';
import Payments from "../views/payments/Payments";

export default class ReferralCharts extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <h1> Hello World</h1>
    );
  }
}

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <ReferralCharts />,
    document.getElementById("channel-referrals-stats-chart")
  );
});
