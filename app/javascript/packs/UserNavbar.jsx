import * as React from "react";
import { createRoot } from "react-dom/client";
import UserNavbar from "../views/admin/components/userNavbar/UserNavbar";

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector("#publisherHeader");
  const props = JSON.parse(element.dataset.props);
  createRoot(element).render(<UserNavbar {...props} />);
});
