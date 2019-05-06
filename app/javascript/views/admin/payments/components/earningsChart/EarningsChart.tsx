import * as React from "react";

import Card from "../../../../../components/card/Card";
import console = require("console");

export default class EarningsChart extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
  }

  public componentDidUpdate() {
    this.createEarningsChart(this.props.transactions);
  }

  public createEarningsChart(transactions) {
    const node = this.node;

    let timestamps = [];
    let contributions = [];
    let referrals = [];
    let fees = [];

    transactions.forEach((transaction, index) => {
      let date = new Date(transaction.created_at);
      console.log(
        date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear()
      );
      switch (transaction.transaction_type) {
        case "contribution_settlement":
          let date1 = new Date(transaction.created_at);
          let timestamp =
            date1.getMonth() +
            1 +
            "/" +
            date1.getDate() +
            "/" +
            date1.getFullYear();
          if (!timestamps.includes(timestamp)) {
            timestamps.push(timestamp);
          }
          contributions.push(Math.abs(transaction.amount).toFixed(2));
          break;
        case "referral_settlement":
          let date2 = new Date(transaction.created_at);
          let timestamp =
            date2.getMonth() +
            1 +
            "/" +
            date2.getDate() +
            "/" +
            date2.getFullYear();
          if (!timestamps.includes(timestamp)) {
            timestamps.push(timestamp);
          }
          referrals.push(Math.abs(transaction.amount).toFixed(2));
          break;
      }
    });

    let referralChartData = {
      labels: timestamps,
      datasets: [
        {
          label: "Contributions",
          data: contributions,
          borderColor: "#A0AAF8",
          backgroundColor: "#A0AAF8",
          fill: true
        },
        {
          label: "Referrals",
          data: referrals,
          borderColor: "#D2D8FD",
          backgroundColor: "#D2D8FD",
          fill: true
        }
      ]
    };

    let referralChartSettings = {
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
      type: "line",
      data: referralChartData
    };

    var myChart = new Chart(node, referralChartSettings);
  }

  public render() {
    return (
      <Card>
        <div
          style={{
            textAlign: "center",
            fontSize: "22px",
            fontWeight: "bold",
            color: "#686978",
            paddingBottom: "18px"
          }}
        >
          Earned To Date
        </div>
        <div
          style={{
            display: "flex",
            alignItems: "center",
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
                  borderRadius: "50%",
                  backgroundColor: "#A0AAF8",
                  height: "16px",
                  width: "16px",
                  marginTop: "12px",
                  marginRight: "4px"
                }}
              />
              <div
                style={{
                  textAlign: "center",
                  fontSize: "16px",
                  color: "#686978",
                  paddingTop: "8px"
                }}
              >
                Contributions
              </div>
            </div>
            <div style={{ display: "flex" }}>
              <div
                style={{
                  borderRadius: "50%",
                  backgroundColor: "#D2D8FD",
                  height: "16px",
                  width: "16px",
                  marginTop: "4px",
                  marginRight: "4px"
                }}
              />
              <div
                style={{
                  textAlign: "center",
                  fontSize: "16px",
                  color: "#686978"
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
