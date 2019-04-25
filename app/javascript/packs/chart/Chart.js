import * as React from "react";
import moment from "moment";
import Chart from "chart.js";

class ReactChart extends React.Component {
  constructor(props) {
    super(props);
    this.chartRef = React.createRef();
    this.getData = this.getData.bind(this);
    this.getOptions = this.getOptions.bind(this);
    this.getSuggestedMax = this.getSuggestedMax.bind(this);
    this.state = {};

    Chart.defaults.global.defaultFontFamily = "Muli";
    Chart.scaleService.updateScaleDefaults("logarithmic", {
      ticks: {
        callback: function(...args) {
          // new default function here
          const value = Chart.Ticks.formatters.logarithmic.call(this, ...args);
          if (value.length) {
            var numericalValue = Number(value);
            return numericalValue >= 1 ? numericalValue.toLocaleString() : "";
          }
          return value;
        }
      }
    });
  }

  componentDidUpdate(prevProps) {
    if (this.props.title === prevProps.title) {
      return;
    }

    if (!this.chart) {
      this.chart = new Chart(document.getElementById("chart-canvas"), {
        type: "line",
        data: this.getData(this.props.data),
        options: this.getOptions(this.props.title, this.props.max)
      });
    } else {
      this.chart.data = this.getData(this.props.data);
      this.chart.options = this.getOptions(
        this.props.title,
        this.getSuggestedMax(this.props.data)
      );
      this.chart.update();
    }
  }

  getData(data) {
    return {
      labels: this.createLabels(data[0]["ymd"]),
      datasets: [
        {
          label: "Downloads",
          data: data.map(x => x.retrievals),
          borderColor: "#F88469",
          fill: false
        },
        {
          label: "Installs",
          data: data.map(x => x.first_runs),
          borderColor: "#66C3FC",
          fill: false
        },
        {
          label: "30-Day-Use",
          data: data.map(x => x.finalized),
          borderColor: "#7B82E1",
          fill: false
        }
      ]
    };
  }

  getOptions(title, suggestedMax) {
    let options = {
      tooltips: {
        mode: "x"
      },
      elements: {
        point: {
          radius: 0,
          hitRadius: 5,
          hoverRadius: 5
        }
      },
      title: {
        fontSize: 18,
        display: true,
        text: title.toUpperCase()
      },
      scales: {
        xAxes: [
          {
            type: "time",
            distribution: "series",
            ticks: {
              autoSkip: true,
              source: "labels"
            },
            time: {
              unit: "day"
            }
          }
        ],
        yAxes: [
          {
            type: "logarithmic",
            ticks: {
              suggestedMax: suggestedMax
            }
          }
        ]
      },
      legend: {
        labels: {
          usePointStyle: true
        }
      }
    };
    return options;
  }

  // Max of the chart is 80% of the suggested max to be used by Chartjs
  getSuggestedMax(data) {
    var currentMax = 0;
    Object.keys(data).forEach(function(key) {
      var value = data[key];
      currentMax =
        value.retrievals > currentMax ? value.retrievals : currentMax;
      currentMax =
        value.first_runs > currentMax ? value.first_runs : currentMax;
      currentMax = value.finalized > currentMax ? value.finalized : currentMax;
    });
    return Math.ceil((currentMax / 95) * 100);
  }

  createLabels(startingDate) {
    // https://stackoverflow.com/questions/7556591/is-the-javascript-date-object-always-one-day-off
    var loop = new Date(startingDate.replace(/-/g, "/"));
    var dateFormat = "YYYY/MM/DD";
    var newDate;
    var datesArray = [];

    while (loop <= new Date()) {
      newDate = moment(loop, dateFormat);
      datesArray.push(newDate);
      loop.setDate(loop.getDate() + 1);
    }

    return datesArray;
  }

  render() {
    return (
      <div>
        {this.props.data && <canvas id="chart-canvas" ref={this.chartRef} />}
      </div>
    );
  }
}

export default ReactChart;
