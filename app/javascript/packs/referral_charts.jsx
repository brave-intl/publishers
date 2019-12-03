import * as React from "react";
import * as ReactDOM from "react-dom";
import styled from "brave-ui/theme";
import Select from "brave-ui/components/formControls/select";
import ControlWrapper from "brave-ui/components/formControls/controlWrapper";
import { PrimaryButton } from "./referrals/ReferralChartsStyle";
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
  }

  viewReferralCodeStats = async () => {
    const node = this.selectMenuRef.current;
    var url =
      this.props.scope === "admin"
        ? routes.admin.promo_registrations.show.path.replace("{publisher_id}", this.props.publisherId)
        : routes.publishers.promo_registrations.show.path.replace("{id}", this.props.publisherId);

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
          this.setState({ stats: json.stats, data: json.data, title: node.state.value });
        }
      });
    });
  }

  componentDidMount = () => {
    if(this.state.referralCodes.length > 0) {
      this.viewReferralCodeStats();
    }
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

        <h5>Statistics</h5>
        <div className="d-flex">
          <div className="mr-3">
            <small>DOWNLOADED</small>
            <div className="font-weight-bold text-center">
              {this.state.stats && this.state.stats.retrievals}
            </div>
          </div>
          <div className="mr-3">
            <small>INSTALLED</small>
            <div className="font-weight-bold text-center">
              {this.state.stats && this.state.stats.first_runs}
            </div>
          </div>
          <div className="mr-3">
            <small>CONFIRMED</small>
            <div className="font-weight-bold text-center">
              {this.state.stats && this.state.stats.finalized}
            </div>
          </div>
        </div>

      </React.Fragment>
    );
  }
}

export function renderReferralCharts(scope) {
  const { value } = document.getElementById("referrals-hidden-tags");
  const publisherId = document.getElementById("publisher_id").value;
  if (value === undefined) {
    return;
  }
  let referralCodes = JSON.parse(value);
  let props = {
    referralCodes: referralCodes,
    scope: scope
  };
  ReactDOM.render(
    <ReferralCharts {...props} publisherId={publisherId} />,
    document.getElementById("channel-referrals-stats-chart")
  );
}
