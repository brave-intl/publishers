document.addEventListener("DOMContentLoaded", function () {
  var jobTime = document.getElementById("job-time");
  var utcDate = new Date(jobTime.innerText);
  jobTime.innerText = utcDate;
});
