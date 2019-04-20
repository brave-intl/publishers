import * as React from "react";

import Card from "../../../../../components/card/Card";

export default class ReferralsChart extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
  }

  public componentDidUpdate() {
    this.createReferralsChart(this.props.referralCode);
  }

  public createReferralsChart(referralCode) {

    let stats = JSON.parse(referralCode.stats)

    const node = this.node;

    let referralChartLabels = []
    let downloads = []
    let installs = []
    let confirmations = []
    stats.forEach((stat) => {
      referralChartLabels.push(stat.ymd)
      downloads.push(stat.retrievals)
      installs.push(stat.first_runs)
      confirmations.push(stat.finalized)
    })

    let referralChartData = {
      labels: referralChartLabels,
      datasets: [
        {
          label: "Downloads",
          data: downloads,
          borderColor: "#FFCD56",
          backgroundColor: "#FFCD56",
          fill: true
        }, 
        {
          label: "Installs",
          data: installs,
          borderColor: "#36A2EB",
          backgroundColor: "#36A2EB",
          fill: true
        }, 
        {
          label: "Confirmations",
          data: confirmations,
          borderColor: "#FF6384",
          backgroundColor: "#FF6384",
          fill: true
        }]
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
