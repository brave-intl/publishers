import Chart from 'chart.js';

function createChart(id, title, dataSource) {

}

function loadDevicesGraph() {
  var ctx = document.getElementById("piwikDevicesChart");
  var devicesDetection = JSON.parse(document.getElementById("piwikDevicesDetection").value);
  var labels = [];
  var visits = [];
  for (let device of devicesDetection) {
    labels.push(device.label);
    visits.push(device.nb_visits);
  }

  var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: labels,
          datasets: [{
              label: 'Device Visits (Past Week) (nb_visits)',
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
  loadDevicesGraph();
}

document.addEventListener('DOMContentLoaded', function() {
  if(document.getElementById("piwikDevicesChart")) {
    loadPiwikData();
  }
});
