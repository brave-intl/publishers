import Chart from 'chart.js';

function createVisitsChart(id, title, dataSource) {
  var wrapper = document.getElementById('wrapper');
  var canvas = document.createElement('canvas');
  canvas.setAttribute("width", "400");
  canvas.setAttribute("height", "100");
  wrapper.appendChild(canvas);

  let visitsSummary = JSON.parse(document.getElementById(dataSource).value);
  var labels = [];
  var visits = [];
  for (let entry of visitsSummary) {
    labels.push(entry.date);
    visits.push(entry.content);
  }

  var myChart = new Chart(canvas, {
      type: 'bar',
      data: {
          labels: labels,
          datasets: [{
              label: title,
              data: visits,
              backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(255, 206, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                  'rgba(153, 102, 255, 0.2)',
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(255, 206, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                  'rgba(153, 102, 255, 0.2)',
                  'rgba(255, 159, 64, 0.2)'
              ],
              borderColor: [
                  'rgba(255,99,132,1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(255, 206, 86, 1)',
                  'rgba(75, 192, 192, 1)',
                  'rgba(153, 102, 255, 1)',
                  'rgba(255,99,132,1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(255, 206, 86, 1)',
                  'rgba(75, 192, 192, 1)',
                  'rgba(153, 102, 255, 1)',
                  'rgba(255, 159, 64, 1)'
              ],
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

function createChart(id, title, dataSource) {
  var wrapper = document.getElementById('wrapper');
  var canvas = document.createElement('canvas');
  canvas.setAttribute("width", "400");
  canvas.setAttribute("height", "100");
  wrapper.appendChild(canvas);

  var devicesDetection = JSON.parse(document.getElementById(dataSource).value);
  var labels = [];
  var visits = [];
  for (let device of devicesDetection) {
    labels.push(device.label);
    visits.push(device.nb_visits);
  }

  var myChart = new Chart(canvas, {
      type: 'bar',
      data: {
          labels: labels,
          datasets: [{
              label: title,
              data: visits,
              backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(255, 206, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                  'rgba(153, 102, 255, 0.2)',
                  'rgba(255, 159, 64, 0.2)'
              ],
              borderColor: [
                  'rgba(255,99,132,1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(255, 206, 86, 1)',
                  'rgba(75, 192, 192, 1)',
                  'rgba(153, 102, 255, 1)',
                  'rgba(255, 159, 64, 1)'
              ],
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
  createChart("piwikDevicesDetectionTypeChart", "Device Visits (Past Week) (nb_visits)", "piwikDevicesDetectionType");
  createChart("piwikDevicesDetectionBrowserVersionsChart", "Browser Versions (Past Week)", "piwikDevicesDetectionBrowserVersions");
  createChart("piwikEventsCategoryChart", "Events (Past Week) (nb_visits)", "piwikEventsCategory");
  createVisitsChart("piwikVisitsSummaryChart", "Visits (Monthly)", "piwikVisitsSummary");
}

document.addEventListener('DOMContentLoaded', function() {
  loadPiwikData();
});
