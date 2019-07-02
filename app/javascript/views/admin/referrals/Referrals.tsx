import * as React from "react";

import { Cell, Container, Grid } from "../../../components/grid/Grid";
import renderReferralCharts from "../../../packs/referral_charts";
import UserNavbar from "../components/userNavbar/UserNavbar";

import { templateAreas, templateRows } from "./ReferralsStyle";

export enum NavbarSelection {
  Dashboard,
  Channels,
  Referrals,
  Payments
}

interface IReferralsProps {
  data: any;
}

export default class Referrals extends React.Component<IReferralsProps, {}> {
  constructor(props) {
    super(props);
    renderReferralCharts("admin");
  }

  public render() {
    return (
      <React.Fragment>
        <UserNavbar navbarSelection={"Referrals"} publisher={this.props.data.publisher} />
        <Container>
          <Grid
            templateAreas={templateAreas}
            templateRows={templateRows}
            style={{ marginTop: "30px", marginBottom: "30px" }}
          >
            <Cell gridArea={"a"} />
          </Grid>
        </Container>
      </React.Fragment>
    );
  }
}
