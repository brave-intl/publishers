import * as React from "react";
import * as ReactDOM from "react-dom";
import 'babel-polyfill';
import styled from 'brave-ui/theme';
import Select from "brave-ui/components/formControls/select";
import ControlWrapper from "brave-ui/components/formControls/controlWrapper";
import { PrimaryButton } from "../publishers/ReferralChartsStyle";
import '../publishers/dashboard_chart';
import routes from "../views/routes";

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
    var url = routes.publishers.promo_registrations.show.path.replace('{id}', document.getElementById('publisher_id').value);
    url = url.replace('{referral_code}', node.state.value);
    console.log(url);
    const result = await fetch(url, {
      headers: {'Accept': 'text/html', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content},
      credentials: 'same-origin',
      method: "GET"
    }).then(response => {
      response.json().then(json => {
        console.log(json);
//        this.setState({ invoices: json.invoices });
      });
    });
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
              <Select type={'light'} ref={this.selectMenuRef} >
                {referralCodesForSelect}
              </Select>
            </div>
        </ControlWrapper>
        <div>
          <div style={{marginTop: '15px', marginLeft: '15px'}}>
            <PrimaryButton onClick={this.viewReferralCodeStats} enabled={true} >
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
