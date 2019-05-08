import * as React from "react";
import * as ReactDOM from "react-dom";
import Referrals from "../../../../views/admin/referrals/Referrals";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("referrals_data");
  const data = JSON.parse(node.getAttribute("data"));
  ReactDOM.render(
    <Referrals data={data} />,
    document
      .getElementById("main-content")
      .appendChild(document.createElement("div"))
  );
});
