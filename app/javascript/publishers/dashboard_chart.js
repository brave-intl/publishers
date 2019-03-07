import Chart from 'chart.js';
import moment from 'moment';

let colors = [
  '255, 99, 132',
  '54, 162, 235',
  '255, 206, 86',
  '75, 192, 192',
  '153, 102, 255',
  '255, 159, 64'
]

function createLabels(startingDate) {
  // https://stackoverflow.com/questions/7556591/is-the-javascript-date-object-always-one-day-off
  var loop = new Date(startingDate.replace(/-/g, '\/'));
  var dates_array = [];

  while (loop <= new Date()) {
    dates_array.push(loop.getFullYear() + '-' + (loop.getMonth() + 1) + '-' + loop.getDate());
    loop.setDate(loop.getDate() + 1);
  }

  return dates_array;
}

// Max of the chart is 80% of the suggested max to be used by Chartjs
function getSuggestedMax(data) {
  var currentMax = 0;
  Object.keys(data).forEach(function (key) {
    var value = data[key];
    currentMax = value.retrievals > currentMax ? value.retrievals : currentMax;
    currentMax = value.first_runs > currentMax ? value.first_runs : currentMax;
    currentMax = value.finalized > currentMax ? value.finalized : currentMax;
  });
  return (currentMax * 100 / 95)
}

function createChart(data, title, suggestedMax) {
  var wrapper = document.getElementById('channel-referrals-stats-chart');
  var canvas = document.getElementById('channel-referrals-stats-chart-canvas');
  if (!canvas) {
    canvas = document.createElement('canvas');
    canvas.setAttribute('id', 'channel-referrals-stats-chart-canvas');
    canvas.setAttribute("width", "400");
    canvas.setAttribute("height", "300");
    wrapper.appendChild(canvas);
  }

  Chart.defaults.global.defaultFontFamily = 'Poppins';

  new Chart(canvas, {
    type: 'line',
    data: {
      labels: createLabels(data[0]['ymd']),
      datasets: [
        {
          label: 'Downloads',
          data: data.map(x => x.retrievals),
          borderColor: '#F88469',
        },
        {
          label: 'Installs',
          data: data.map(x => x.first_runs),
          borderColor: '#7B82E1',
        },
        {
          label: '30-Day-Use',
          data: data.map(x => x.finalized),
          borderColor: '#66C3FC',
        },
      ]
    },
    options: {
      tooltips: {
        mode: 'x'
      },
      title: {
        fontSize: 18,
        display: true,
        text: title.toUpperCase()
      },
      scales: {
        yAxes: [{
          ticks: {
            suggestedMax: suggestedMax
          }
        }]
      }
    }
  });
}
