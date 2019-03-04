import * as React from "react";
import * as ReactDOM from "react-dom";
import 'babel-polyfill';
import styled from 'brave-ui/theme';
import Select from "brave-ui/components/formControls/select";
import ControlWrapper from "brave-ui/components/formControls/controlWrapper";
import { PrimaryButton } from "../publishers/ReferralChartsStyle";
// import '../publishers/dashboard_chart';
import routes from "../views/routes";
import Chart from 'chart.js';
import moment from 'moment';


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

  createLabels(startingDate) {
    // https://stackoverflow.com/questions/7556591/is-the-javascript-date-object-always-one-day-off
    var loop = new Date(startingDate.replace(/-/g, '\/'));
    var dates_array = [];

    while (loop <= new Date()) {
      dates_array.push(loop.getFullYear() + '-' + (loop.getMonth() + 1) + '-' + loop.getDate());
      loop.setDate(loop.getDate() + 1);
    }

    return dates_array;
  }

  // Max of the chart is 80% of the suggested max to be used by Chartjs
  getSuggestedMax(data) {
    var currentMax = 0;
    Object.keys(data).forEach(function (key) {
      var value = data[key];
      currentMax = value.retrievals > currentMax ? value.retrievals : currentMax;
      currentMax = value.first_runs > currentMax ? value.first_runs : currentMax;
      currentMax = value.finalized > currentMax ? value.finalized : currentMax;
    });
    return (currentMax * 100 / 95)
  }

  createChart(data, title, suggestedMax) {
    var wrapper = document.getElementById('channel-referrals-stats-chart');
    var canvas = document.getElementById('chart-canvas');
    if (canvas) {}
    else {
      canvas = document.createElement('canvas');
      canvas.setAttribute("id", 'chart-canvas');
      canvas.setAttribute("width", "400");
      canvas.setAttribute("height", "300");
      wrapper.appendChild(canvas);
    }

    Chart.defaults.global.defaultFontFamily = 'Poppins';

    new Chart(canvas, {
      type: 'line',
      data: {
        labels: this.createLabels(data[0]['ymd']),
        datasets: [
          {
            label: 'Downloads',
            data: data.map(x => x.retrievals),
            borderColor: '#F88469',
          },
          {
            label: 'Installs',
            data: data.map(x => x.first_runs),
            borderColor: '#7B82E1',
          },
          {
            label: '30-Day-Use',
            data: data.map(x => x.finalized),
            borderColor: '#66C3FC',
          },
        ]
      },
      options: {
        tooltips: {
          mode: 'x'
        },
        title: {
          fontSize: 18,
          display: true,
          text: title.toUpperCase()
        },
        scales: {
          yAxes: [{
            ticks: {
              suggestedMax: suggestedMax
            }
          }]
        }
      }
    });
  }

  async viewReferralCodeStats() {
    const node = this.selectMenuRef.current;
    var url = routes.publishers.promo_registrations.show.path.replace('{id}', document.getElementById('publisher_id').value);
    url = url.replace('{referral_code}', node.state.value);
    const result = await fetch(url, {
      headers: {'Accept': 'text/html', 'X-Requested-With': 'XMLHttpRequest', 'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content},
      credentials: 'same-origin',
      method: "GET"
    }).then(response => {
      response.json().then(json => {
        if (json !== undefined && json.length != 0) {
          this.createChart(json, node.state.value, this.getSuggestedMax(json));
        }
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
          text={'Choose a Referral Code to view its Stats'}
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
