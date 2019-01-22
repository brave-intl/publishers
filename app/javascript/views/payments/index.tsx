import * as React from "react";

import { Wrapper, Container, Grid } from "../style";
import UpholdCard from "./upholdCard";

export default class Referrals extends React.Component {
  public render() {
    return (
      <Wrapper>
        <Container>
          <Grid>
            <UpholdCard name="AliceBlogette" />
          </Grid>
        </Container>
      </Wrapper>
    );
  }
}
