import * as React from "react";

import Chart from "chart.js";
import Card from "../../../../../components/card/Card";

interface ICurrentChartProps {
  referralBalance: any;
  contributionBalance: any;
}

export default class CurrentChart extends React.Component<
  ICurrentChartProps,
  {}
> {
  private node;
  constructor(props) {
    super(props);
  }

  public componentDidMount() {
    this.createCurrentChart(
      this.props.contributionBalance,
      this.props.referralBalance
    );
  }

  public createCurrentChart(contributionBalance, referralBalance) {
    const node = this.node;

    const currentChartData = {
      datasets: [
        {
          backgroundColor: ["#D2D8FD", "#A0AAF8"],
          data: [referralBalance, contributionBalance]
        }
      ],
      labels: ["Referrals", "Contributions"]
    };

    const currentChartSettings = {
      data: currentChartData,
      options: {
        legend: { display: false },
        responsive: false
      },
      type: "doughnut"
    };

    const myChart = new Chart(node, currentChartSettings);
  }

  public render() {
    return (
      <Card>
        <div
          style={{
            color: "#686978",
            fontSize: "22px",
            fontWeight: "bold",
            paddingBottom: "18px",
            textAlign: "center"
          }}
        >
          Current Cycle
        </div>
        <div
          style={{
            alignItems: "center",
            display: "flex",
            justifyContent: "center"
          }}
        >
          <canvas
            style={{ height: "300px", width: "300px" }}
            ref={node => (this.node = node)}
          />
        </div>
        <div style={{ display: "flex", justifyContent: "center" }}>
          <div>
            <div style={{ display: "flex", marginTop: "23px" }}>
              <div
                style={{
                  backgroundColor: "#A0AAF8",
                  borderRadius: "50%",
                  height: "16px",
                  marginRight: "4px",
                  marginTop: "12px",
                  width: "16px"
                }}
              />
              <div
                style={{
                  color: "#686978",
                  fontSize: "16px",
                  paddingTop: "8px",
                  textAlign: "center"
                }}
              >
                Contributions
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
                Referrals
              </div>
            </div>
          </div>
        </div>
      </Card>
    );
  }
}
