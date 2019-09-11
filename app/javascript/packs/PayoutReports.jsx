import * as React from "react";
import * as ReactDOM from "react-dom";
import CurrentChart from "../views/admin/payments/components/currentChart/CurrentChart"

document.addEventListener("DOMContentLoaded", () => {
  const props = JSON.parse(document.getElementById('current-chart').dataset.props)


  ReactDOM.render(
    <CurrentChart {...props} />,
    document.getElementById("current-chart")
  );
});
