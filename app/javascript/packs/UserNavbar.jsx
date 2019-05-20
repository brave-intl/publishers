import * as React from "react";
import * as ReactDOM from "react-dom";
import UserNavbar from "../views/admin/components/userNavbar/UserNavbar";

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector("#publisherHeader");
  const props = JSON.parse(element.dataset.props);
  ReactDOM.render(<UserNavbar {...props} />, element);
});
