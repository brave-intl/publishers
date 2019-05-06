import * as React from "react";

import Chart from "chart.js";
import Card from "../../../../../components/card/Card";

interface IEarningsChartProps {
  transactions: any;
}

export default class EarningsChart extends React.Component<
  IEarningsChartProps,
  {}
> {
  private node;
  constructor(props) {
    super(props);
  }

  public componentDidUpdate() {
    this.createEarningsChart(this.props.transactions);
  }

  public createEarningsChart(transactions) {
    const node = this.node;

    const timestamps = [];
    const contributions = [];
    const referrals = [];
    const fees = [];

    transactions.forEach((transaction, index) => {
      const date = new Date(transaction.created_at);
      switch (transaction.transaction_type) {
        case "contribution_settlement":
          const date1 = new Date(transaction.created_at);
          const timestamp1 =
            date1.getMonth() +
            1 +
            "/" +
            date1.getDate() +
            "/" +
            date1.getFullYear();
          if (!timestamps.includes(timestamp1)) {
            timestamps.push(timestamp1);
          }
          contributions.push(Math.abs(transaction.amount).toFixed(2));
          break;
        case "referral_settlement":
          const date2 = new Date(transaction.created_at);
          const timestamp2 =
            date2.getMonth() +
            1 +
            "/" +
            date2.getDate() +
            "/" +
            date2.getFullYear();
          if (!timestamps.includes(timestamp2)) {
            timestamps.push(timestamp2);
          }
          referrals.push(Math.abs(transaction.amount).toFixed(2));
          break;
      }
    });

    const referralChartData = {
      datasets: [
        {
          backgroundColor: "#A0AAF8",
          borderColor: "#A0AAF8",
          data: contributions,
          fill: true,
          label: "Contributions"
        },
        {
          backgroundColor: "#D2D8FD",
          borderColor: "#D2D8FD",
          data: referrals,
          fill: true,
          label: "Referrals"
        }
      ],
      labels: timestamps
    };

    const referralChartSettings = {
      data: referralChartData,
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

    const myChart = new Chart(node, referralChartSettings);
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
          Earned To Date
        </div>
        <div
          style={{
            alignItems: "center",
            display: "flex",
            justifyContent: "center"
          }}
        >
          <canvas
            style={{ height: "300px", width: "700px" }}
            ref={node => (this.node = node)}
          />
        </div>
        <div style={{ display: "flex", justifyContent: "center" }}>
          <div>
            <div
              style={{
                display: "flex",
                justifyContent: "center",
                marginTop: "16px"
              }}
            >
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
