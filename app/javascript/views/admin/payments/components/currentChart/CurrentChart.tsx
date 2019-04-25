import * as React from "react";

import Card from "../../../../../components/card/Card";

export default class CurrentChart extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
  }

  public componentDidUpdate() {
    this.createCurrentChart();
  }

  public createCurrentChart() {

    const node = this.node;

    let currentChartData = {
      datasets: [{
        data: [500, 700]
        backgroundColor: ["#2FB9A8", "#86DBAF"]
      }]
    }

    let currentChartSettings = {
      options: {
          responsive: false
      },
      type: "doughnut"
      data: currentChartData  
    }

    var myChart = new Chart(node, currentChartSettings)
  }

  public render() {
    return (
      <Card style={{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
        <canvas style={{height: '300px', width: '300px'}} ref={node => (this.node = node)} />
      </Card>
    );
  }
}
