import * as React from "react";

import { Container, Grid, Wrapper } from "../style";

import ReferralsCard from "./referralsCard/index";
import ReferralsHeader from "./referralsHeader/index";
import ReferralsNav from "./referralsNav/index";

export default class Referrals extends React.Component {
  public render() {
    return (
      <Wrapper>
        <ReferralsNav />
        <Container>
          <ReferralsHeader />
          <Grid>
            <ReferralsCard />
            <ReferralsCard />
            <ReferralsCard />
            <ReferralsCard />
          </Grid>
        </Container>
      </Wrapper>
    );
  }
}
