import * as React from "react";
import * as ReactDOM from "react-dom";
import Payments from "../../../../views/admin/payments/Payments";

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <Payments />,
    document
      .getElementById("main-content")
      .appendChild(document.createElement("div"))
  );
});
