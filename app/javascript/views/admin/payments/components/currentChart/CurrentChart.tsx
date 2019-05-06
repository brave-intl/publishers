import * as React from "react";

import Card from "../../../../../components/card/Card";

export default class CurrentChart extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
  }

  public componentDidUpdate() {
    this.createCurrentChart(this.props.contributionBalance, this.props.referralBalance);
  }

  public createCurrentChart(contributionBalance, referralBalance) {

    const node = this.node;

    let currentChartData = {
      datasets: [{
        data: [contributionBalance, referralBalance]
        backgroundColor: ["#D2D8FD", "#A0AAF8"]
      }],
      labels: ["Referrals", "Contributions"]
    }

    let currentChartSettings = {
      options: {
          responsive: false,
          legend: {display: false}
      },
      type: "doughnut",
      data: currentChartData
    }

    var myChart = new Chart(node, currentChartSettings)
  }

  public render() {
    return (
      <Card>
        <div style={{textAlign: 'center', fontSize: '22px', fontWeight: "bold", color: "#686978", paddingBottom: "18px"}}>Current Cycle</div>
        <div style={{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
        <canvas style={{height: '300px', width: '300px'}} ref={node => (this.node = node)} />
        </div>
        <div style={{display: "flex", justifyContent: "center"}}>
        <div>
        <div style={{display: "flex", marginTop: "23px"}}>
        <div style={{borderRadius: "50%", backgroundColor: "#A0AAF8", height: "16px", width: "16px", marginTop: "12px", marginRight: "4px"}}></div>
        <div style={{textAlign: 'center', fontSize: '16px', color: "#686978", paddingTop: "8px"}}>Contributions</div>
        </div>
        <div style={{display: "flex"}}>
        <div style={{borderRadius: "50%", backgroundColor: "#D2D8FD", height: "16px", width: "16px", marginTop: "4px", marginRight: "4px"}}></div>
        <div style={{textAlign: 'center', fontSize: '16px', color: "#686978"}}>Referrals</div>
        </div>
        </div>
        </div>


      </Card>
    );
  }
}
