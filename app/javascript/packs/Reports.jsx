import * as React from "react";
import * as ReactDOM from "react-dom";
import Reports from "../views/reports/Reports";

document.addEventListener("DOMContentLoaded", () => {
  const reactElement = document.createElement("div");
  reactElement.id = "react-content";
  document.getElementById("main-content").appendChild(reactElement);

  const data = JSON.parse(
    document.getElementById("reactData").getAttribute("data-react")
  );

  ReactDOM.render(
    <Reports {...data} />,
    document.getElementById("react-content")
  );
});
