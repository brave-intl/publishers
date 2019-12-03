import * as React from "react";
import * as ReactDOM from "react-dom";
import Payments from "../../../../views/admin/payments/Payments";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("payments_data");
  const data = JSON.parse(node.getAttribute("data"));
  ReactDOM.render(
    <Payments data={data} />,
    document
      .getElementById("main-content")
      .appendChild(document.createElement("div"))
  );
});
