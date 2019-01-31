import * as React from "react";
import * as ReactDOM from "react-dom";
import Reports from "../views/reports/Reports";

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <Reports />,
    document.body.appendChild(
      document.getElementsByClassName("main-content")[0]
    )
  );
});
