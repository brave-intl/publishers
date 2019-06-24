import * as React from "react";
import * as ReactDOM from "react-dom";
import "babel-polyfill";
import styled from "brave-ui/theme";
import Select from "brave-ui/components/formControls/select";
import ControlWrapper from "brave-ui/components/formControls/controlWrapper";
import { PrimaryButton } from "../publishers/ReferralChartsStyle";
// import "../publishers/dashboard_chart";
import routes from "../views/routes";
import ReactChart from "./chart/Chart";
import { ThemeProvider } from "brave-ui/theme";
import Theme from "brave-ui/theme/brave-default";

export default class ReferralCharts extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      referralCodes: this.props.referralCodes
    };
    this.selectMenuRef = React.createRef();
    this.bindFunctions();
  }

  bindFunctions() {
    this.viewReferralCodeStats = this.viewReferralCodeStats.bind(this);
  }

  async viewReferralCodeStats() {
    const node = this.selectMenuRef.current;
    var url = routes.publishers.promo_registrations.show.path.replace("{id}", this.props.publisherId);
    url = url.replace("{referral_code}", node.state.value);
    const result = await fetch(url, {
      headers: {
        Accept: "text/html",
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": document.head.querySelector("[name=csrf-token]").content
      },
      credentials: "same-origin",
      method: "GET"
    }).then(response => {
      response.json().then(json => {
        if (json !== undefined && json.length != 0) {
          this.setState({ data: json, title: node.state.value });
        }
      });
    });
  }

  render() {
    var referralCodesForSelect = [];
    this.state.referralCodes.forEach(function(element) {
      referralCodesForSelect.push(
        <div data-value={element} key={element}>
          {element}
        </div>
      );
    });

    return (
      <React.Fragment>
        <div className="referral-graph">
          <h4>Referral Graph</h4>

          <ThemeProvider theme={Theme}>
            <Select ref={this.selectMenuRef}>{referralCodesForSelect}</Select>
          </ThemeProvider>
          <PrimaryButton onClick={this.viewReferralCodeStats} enabled={true}>
            View stats
          </PrimaryButton>
        </div>
        <ReactChart data={this.state.data} title={this.state.title} />
      </React.Fragment>
    );
  }
}

export function renderReferralCharts() {
  const { value } = document.getElementById("referrals-hidden-tags");
  const publisherId = document.getElementById("publisher_id").value;
  if (value === undefined) {
    return;
  }
  let referralCodes = JSON.parse(value);
  let props = {
    referralCodes: referralCodes
  };
  ReactDOM.render(
    <ReferralCharts {...props} publisherId={publisherId} />,
    document.getElementById("channel-referrals-stats-chart")
  );
}
