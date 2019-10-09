import * as React from "react";
import * as ReactDOM from "react-dom";
import Statements from "../views/statements/Statements";

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <Statements />,
    document.getElementsByClassName("statements")[0]
  );
});
