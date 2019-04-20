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

    let referralChartLabels = []
    let contributions = []
    let referrals = []
    let fees = []

    transactions.forEach((transaction, index) => {
        switch (transaction.transaction_type) {
            case "contribution_settlement":
                if (!referralChartLabels.includes(transaction.created_at)){
                    referralChartLabels.push(transaction.created_at)
                }
                contributions.push(Math.abs(transaction.amount))
                break;
            case "referral_settlement":
                if (!referralChartLabels.includes(transaction.created_at)){
                    referralChartLabels.push(transaction.created_at)
                }
                referrals.push(Math.abs(transaction.amount))
                break;
            case "fee":
            if (!referralChartLabels.includes(transaction.created_at)){
                referralChartLabels.push(transaction.created_at)
            }
            fees.push(Math.abs(transaction.amount))
            break;
        }
    })

    let referralChartData = {
      labels: referralChartLabels,
      datasets: [
        {
          label: "Contributions",
          data: contributions,
          borderColor: "#36A2EB",
          backgroundColor: "#36A2EB",

          fill: true
        }, 
        {
          label: "Referrals",
          data: referrals,
          borderColor: "#FFCD56",
          backgroundColor: "#FFCD56",

          fill: true
        },
        {
            label: "Fees",
            data: fees,
            borderColor: "#FF6384",
            backgroundColor: "#FF6384",
  
            fill: true
          }
    }

    let referralChartSettings = {
      options: {
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
      data: referralChartData  
    }

    var myChart = new Chart(node, referralChartSettings)
  }

  public render() {
    return (
      <Card>
        <canvas ref={node => (this.node = node)} />
      </Card>
    );
  }
}
