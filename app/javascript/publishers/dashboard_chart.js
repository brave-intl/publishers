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

function createLabels() {
  var startingDate = new Date(document.getElementById('all-channels-referral-stats-starting-month').value);
  var endDate = new Date();
  var loop = new Date(startingDate);

  var dates_array = [];

  while (loop <= endDate) {
    dates_array.push(loop.getFullYear() + '-' + (loop.getMonth() + 1) + '-' + loop.getDay());
    if (loop.getMonth() == 11) {
      loop.setYear(loop.getFullYear() + 1);
    }
    loop.setDate(loop.getDate() + 1);
  }

  return dates_array;
}

function createCharts() {
  JSON.parse(document.getElementById('referrals-hidden-tags').value).forEach(function (element) {
    createChart(JSON.parse(document.getElementById(element).value, "EPL566"));
  });
}

function createChart(data, title) {
  var wrapper = document.getElementById('channel-referrals-stats-chart');
  var canvas = document.createElement('canvas');
  canvas.setAttribute("width", "400");
  canvas.setAttribute("height", "100");
  wrapper.appendChild(canvas);

  new Chart(canvas, {
    type: 'line',
    data: {
      labels: createLabels(),
      datasets: [
        {
          label: 'Retrievals',
          data: data.map(x => x.retrievals),
          borderColor: '#F88469',
        },
        {
          label: 'First Runs',
          data: data.map(x => x.first_runs),
          borderColor: '#7B82E1',
        },
        {
          label: 'Finalized',
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
        display: true,
        text: 'EPL566'
      }
    }
  });
}

document.addEventListener('DOMContentLoaded', function () {
  if (window.location.pathname === '/publishers/home') {
    createCharts();
  }
});
