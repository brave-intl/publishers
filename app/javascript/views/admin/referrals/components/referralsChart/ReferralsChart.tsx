import * as React from "react";

import Select from "brave-ui/components/formControls/select";
import Chart from "chart.js";
import Card from "../../../../../components/card/Card";

interface IReferralsChartProps {
  referralCodes: any;
}

interface IReferralsChartState {
  selectedReferralCode: any;
}

export default class Referrals extends React.Component<
  IReferralsChartProps,
  IReferralsChartState
> {
  private node;
  constructor(props) {
    super(props);
    this.state = {
      selectedReferralCode: 0
    };
  }

  public componentDidMount() {
    this.createReferralsChart(
      this.props.referralCodes[this.state.selectedReferralCode]
    );
  }

  public componentDidUpdate() {
    this.createReferralsChart(
      this.props.referralCodes[this.state.selectedReferralCode]
    );
  }

  public handleReferralCodeSelect = e => {
    this.setState({ selectedReferralCode: e.target.value });
  };

  public createReferralsChart(referralCode) {
    const node = this.node;

    const stats = referralCode.stats;
    const chartLabels = [];
    const downloads = [];
    const installs = [];
    const confirmations = [];

    stats.forEach(stat => {
      chartLabels.push(stat.date);
      downloads.push(stat.downloads);
      installs.push(stat.installs);
      confirmations.push(stat.confirmations);
    });

    const chartData = {
      datasets: [
        {
          backgroundColor: "#DFF3FE",
          borderColor: "#DFF3FE",
          data: downloads,
          fill: true,
          label: "Downloads"
        },
        {
          backgroundColor: "#D2D8FD",
          borderColor: "#D2D8FD",
          data: installs,
          fill: true,
          label: "Installs"
        },
        {
          backgroundColor: "#A0AAF8",
          borderColor: "#A0AAF8",
          data: confirmations,
          fill: true,
          label: "Confirmations"
        }
      ],
      labels: chartLabels
    };

    const chartSettings = {
      data: chartData,
      options: {
        legend: {
          display: false
        },
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
    };

    const myChart = new Chart(node, chartSettings);
  }

  public render() {
    return (
      <Card>
        <div
          style={{
            color: "#686978",
            fontSize: "22px",
            fontWeight: "bold",
            paddingBottom: "10px",
            textAlign: "center"
          }}
        >
          Referrals Stats
        </div>
        <div
          style={{
            alignItems: "center",
            display: "flex",
            justifyContent: "center",
            width: "100%"
          }}
        >
          <canvas
            style={{ height: "400px", width: "100%" }}
            ref={node => (this.node = node)}
          />
        </div>
        <div
          style={{
            margin: "auto",
            paddingTop: "20px",
            textAlign: "center",
            width: "25%"
          }}
        >
          <ReferralCodeSelect
            referralCodes={this.props.referralCodes}
            handleReferralCodeSelect={this.handleReferralCodeSelect}
          />
        </div>
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            marginTop: "24px"
          }}
        >
          <div>
            <div style={{ display: "flex" }}>
              <div
                style={{
                  backgroundColor: "#A0AAF8",
                  borderRadius: "50%",
                  height: "16px",
                  marginRight: "4px",
                  marginTop: "4px",
                  width: "16px"
                }}
              />
              <div
                style={{
                  color: "#686978",
                  fontSize: "16px",
                  textAlign: "center"
                }}
              >
                Confirmation
              </div>
            </div>
            <div style={{ display: "flex" }}>
              <div
                style={{
                  backgroundColor: "#D2D8FD",
                  borderRadius: "50%",
                  height: "16px",
                  marginRight: "4px",
                  marginTop: "4px",
                  width: "16px"
                }}
              />
              <div
                style={{
                  color: "#686978",
                  fontSize: "16px",
                  textAlign: "center"
                }}
              >
                Installs
              </div>
            </div>
            <div style={{ display: "flex" }}>
              <div
                style={{
                  backgroundColor: "#DFF3FE",
                  borderRadius: "50%",
                  height: "16px",
                  marginRight: "4px",
                  marginTop: "4px",
                  width: "16px"
                }}
              />
              <div
                style={{
                  color: "#686978",
                  fontSize: "16px",
                  textAlign: "center"
                }}
              >
                Downloads
              </div>
            </div>
          </div>
        </div>
      </Card>
    );
  }
}

function ReferralCodeSelect(props) {
  const dropdownOptions = props.referralCodes.map((referralCode, index) => (
    <option key={index} value={index}>
      {referralCode.referralCode}
    </option>
  ));
  return (
    <select
      onChange={e => {
        props.handleReferralCodeSelect(e);
      }}
    >
      {dropdownOptions}
    </select>
  );
}
