import Chart from 'chart.js';

let colors = [
  '255, 99, 132',
  '54, 162, 235',
  '255, 206, 86',
  '75, 192, 192',
  '153, 102, 255',
  '255, 159, 64'
]

function createChart() {
  var wrapper = document.getElementById('publisherStats');
  var canvas = document.createElement('canvas');
  canvas.setAttribute("width", "400");
  canvas.setAttribute("height", "100");
  wrapper.appendChild(canvas);

  var allPublishers = JSON.parse(document.getElementById('all_publishers').value);
  var emailVerified = JSON.parse(document.getElementById('email_verified').value);
  var emailVerifiedWithChannel = JSON.parse(document.getElementById('email_verified_with_channel').value);
  var emailVerifiedWithVerifiedChannel = JSON.parse(document.getElementById('email_verified_with_verified_channel').value);

  new Chart(canvas, {
    type: 'bar',
    data: {
      labels: allPublishers.map(x => x.label),
      datasets: [
        {
          label: 'All publishers',
          data: allPublishers.map(x => x.value),
          backgroundColor: '#F88469',
        },
        {
          label: 'Email Verified',
          data: emailVerified.map(x => x.value),
          backgroundColor: '#7B82E1',
        },
        {
          label: 'Email Verified with Channel',
          data: emailVerifiedWithChannel.map(x => x.value),
          backgroundColor: '#66C3FC',
        },
        {
          label: 'Email Verified with Verified Channel',
          data: emailVerifiedWithVerifiedChannel.map(x => x.value),
          backgroundColor: '#96DFBA',
        },
      ]
    },
    options: {
      scales: {
        xAxes: [{
          offset: true,
          type: 'time',
          time: {
            parser: 'YYYY-MM-DD',
            tooltipFormat: 'll',
            displayFormats: {
              'day': 'YYYY-MM-DD'
            }
          },
          categoryPercentage: 0.5,
          scaleLabel: {
            display: true,
            labelString: 'Date'
          }
        }],
        yAxes: [{
          ticks: {
            beginAtZero: true
          }
        }]
      }
    }
  });
}

document.addEventListener('DOMContentLoaded', function () {
  if (window.location.href.indexOf('publisher_statistics') !== -1) {
    createChart();
  }
});
