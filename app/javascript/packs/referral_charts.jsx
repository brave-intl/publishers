import * as React from "react";
import * as ReactDOM from "react-dom";
import 'babel-polyfill';
import styled from 'brave-ui/theme';
import Select from "brave-ui/components/formControls/select";
import ControlWrapper from "brave-ui/components/formControls/controlWrapper";
import { PrimaryButton } from "../publishers/ReferralChartsStyle";
import '../publishers/dashboard_chart';

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
      <div style={{display: 'inline-flex', flexDirection: 'row', justifyContent: 'flex-start'}}>
        <ControlWrapper
          text={'Choose Referral Code to view its Stats'}
          type={'light'}>
            <div style={{maxWidth: "350px"}} >
              <Select type={'light'} >
                {referralCodesForSelect}
              </Select>
            </div>
        </ControlWrapper>
        <div>
          <div style={{marginTop: '15px', marginLeft: '15px'}}>
            <PrimaryButton enabled={true} >
              View
            </PrimaryButton>
          </div>
        </div>
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
