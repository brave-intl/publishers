// Service run times are rendered in UTC so the page is readable without JS.
// Rewrite them to the admin's local time, parsing the machine-readable
// `datetime` attribute rather than the displayed text.
document.addEventListener("DOMContentLoaded", function () {
  var jobTimes = document.getElementsByClassName("job-time");

  for (var i = 0; i < jobTimes.length; i++) {
    var element = jobTimes[i];
    var localDate = new Date(element.getAttribute("datetime"));

    if (!isNaN(localDate.getTime())) {
      element.innerText = localDate.toLocaleString();
    }
  }
});
