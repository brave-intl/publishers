import Chart from 'chart.js';

let colors = [
  '255, 99, 132',
  '54, 162, 235',
  '255, 206, 86',
  '75, 192, 192',
  '153, 102, 255',
  '255, 159, 64'
]

function createChart(id, title, type, dataSource) {
  var wrapper = document.getElementById('wrapper');
  var canvas = document.createElement('canvas');
  canvas.setAttribute("width", "400");
  canvas.setAttribute("height", "100");
  wrapper.appendChild(canvas);

  var data = JSON.parse(document.getElementById(dataSource).value);
  var labels = [];
  var visits = [];
  let backgroundColor = [];
  let borderColor = [];

  switch(type) {
    case 'Visits':
    for (let entry of data) {
      labels.push(entry.date);
      visits.push(entry.content);
      }
        break;
    case 'Devices':
    for (let entry of data) {
      labels.push(entry.label);
      visits.push(entry.nb_visits);
    }
        break;
    case 'Events':
    for (let entry of data) {
      labels.push(entry.label);
      visits.push(entry.nb_visits);
    }
      break;
    }

    for(let i = 0; i < data.length; i++){
      backgroundColor.push('rgba(' + colors[i%5]+ ', 0.2)')
      borderColor.push('rgba(' + colors[i%5] + ', 1)')
    }

  var myChart = new Chart(canvas, {
      type: 'bar',
      data: {
          labels: labels,
          datasets: [{
              label: title,
              data: visits,
              backgroundColor: backgroundColor,
              borderColor: borderColor,
              borderWidth: 1
          }]
      },
      options: {
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero:true
            }
          }]
        }
      }
  });
}

function loadPiwikData() {
  createChart("piwikDevicesDetectionTypeChart", "Device Visits (Past Week) (nb_visits)", 'Devices', "piwikDevicesDetectionType");
  createChart("piwikDevicesDetectionBrowserVersionsChart", "Browser Versions (Past Week)", 'Devices', "piwikDevicesDetectionBrowserVersions");
  createChart("piwikEventsCategoryChart", "Events (Past Week) (nb_visits)", 'Events', "piwikEventsCategory");
  createChart("piwikVisitsSummaryChart", "Visits (Monthly)", 'Visits', "piwikVisitsSummary");
}

document.addEventListener('DOMContentLoaded', function() {
  loadPiwikData();
});
