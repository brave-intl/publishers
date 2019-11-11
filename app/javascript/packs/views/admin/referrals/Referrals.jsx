import * as React from "react";
import * as ReactDOM from "react-dom";
import UserNavbar from '../../../../views/admin/components/userNavbar/UserNavbar'
import { renderReferralCharts } from "../../../../packs/referral_charts";

document.addEventListener("DOMContentLoaded", () => {
  const props = JSON.parse(document.getElementById('publisherHeader').dataset.props);
  ReactDOM.render(
    <UserNavbar navbarSelection={"Referrals"} publisher={props.publisher} />,
    document.getElementById("publisherHeader")
  );

  renderReferralCharts("admin");
});
