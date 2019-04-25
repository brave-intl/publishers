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

    let referralChartLabels = [
      "9/1",
      "10/1",
      "11/1",
      "12/1",
      "1/1",
      "2/1",
      "3/1",
      "4/1"
    ];
    let contributions = [];
    let referrals = [];
    let fees = [];

    // transactions.forEach((transaction, index) => {
    //   switch (transaction.transaction_type) {
    //     case "contribution_settlement":
    //       if (!referralChartLabels.includes(transaction.created_at)) {
    //         referralChartLabels.push(transaction.created_at);
    //       }
    //       contributions.push(Math.abs(transaction.amount));
    //       break;
    //     case "referral_settlement":
    //       if (!referralChartLabels.includes(transaction.created_at)) {
    //         referralChartLabels.push(transaction.created_at);
    //       }
    //       referrals.push(Math.abs(transaction.amount));
    //       break;
    //     case "fee":
    //       if (!referralChartLabels.includes(transaction.created_at)) {
    //         referralChartLabels.push(transaction.created_at);
    //       }
    //       fees.push(Math.abs(transaction.amount));
    //       break;
    //   }
    // });

    let referralChartData = {
      labels: referralChartLabels,
      datasets: [
        {
          label: "Contributions",
          data: [50, 75, 73, 40, 50, 67, 75, 112],
          borderColor: "#36A2EB",
          backgroundColor: "#36A2EB",
          fill: true
        },
        {
          label: "Referrals",
          data: [10, 25, 53, 25, 40, 67, 33, 50],
          borderColor: "#FFCD56",
          backgroundColor: "#FFCD56",
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
      <Card
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center"
        }}
      >
        <canvas
          style={{ height: "300px", width: "700px", marginTop: "20px" }}
          ref={node => (this.node = node)}
        />
      </Card>
    );
  }
}
