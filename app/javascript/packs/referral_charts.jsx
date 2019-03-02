import * as React from "react";
import * as ReactDOM from "react-dom";
import Select from "brave-ui/components/formControls/select";
import ControlWrapper from "brave-ui/components/formControls/controlWrapper";
import '../publishers/dashboard_chart';
import Payments from "../views/payments/Payments";

export default class ReferralCharts extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      referralCodes: this.props.referralCodes
    };
  }

  render() {
    var referralCodesForSelect = [];
    this.state.referralCodes.forEach(function(element) {
      referralCodesForSelect.push(<div data-value={element}>{element}</div>);
    });
    return (
      <div>
        <ControlWrapper
          text={'Choose Referral Code to view its Stats'}
          type={'light'}>
          <Select type={'light'} >
            {referralCodesForSelect}
          </Select>
        </ControlWrapper>
      </div>
    );
  }
}

export function renderReferralCharts() {
  let props = {
    referralCodes: JSON.parse(document.getElementById('referrals-hidden-tags').value)
  };
  ReactDOM.render(
    <ReferralCharts {...props}/>,
    document.getElementById("channel-referrals-stats-chart")
  );
}
