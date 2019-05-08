import * as React from "react";

import { Cell, Container, Grid } from "../../../components/grid/Grid";
import UserNavbar from "../components/userNavbar/UserNavbar";
import ReferralsChart from "./components/referralsChart/ReferralsChart";
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
  }

  public render() {
    return (
      <React.Fragment>
        <UserNavbar
          navbarSelection={NavbarSelection.Referrals}
          name={this.props.data.name}
          userID={this.props.data.userID}
          status={this.props.data.status}
        />
        <Container>
          <Grid
            templateAreas={templateAreas}
            templateRows={templateRows}
            style={{ marginTop: "30px", marginBottom: "30px" }}
          >
            <Cell gridArea={"a"}>
              {console.log(this.props.data.referralCodes)}
              <ReferralsChart referralCodes={this.props.data.referralCodes} />
            </Cell>
          </Grid>
        </Container>
      </React.Fragment>
    );
  }
}
