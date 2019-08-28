import * as React from "react";
import * as ReactDOM from "react-dom";
import StatementDetails from "../views/statements/statements/StatementDetails";

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector("#statement_details");
  console.log(element.dataset);
  const statement = JSON.parse(element.dataset.statement);

  ReactDOM.render(
    <StatementDetails statement={statement} showPage={true} />,
    document.getElementById("statement_details")
  );
});
