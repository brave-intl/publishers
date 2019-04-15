import * as React from "react";

import Card from "../../../../components/card/Card";
import {
  Avatar,
  Container,
  Name,
  Nav,
  Section,
  Status
} from "./UserNavbarStyle";

export default class Referrals extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {};
  }

  public render() {
    return (
      <Card>
        <Container>
          <Section>
            <Avatar />
            <Name>Dan</Name>
            <Status>Active</Status>
          </Section>
          <Section>
            <Nav>Overview</Nav>
            <Nav>Channels</Nav>
            <Nav>Referrals</Nav>
            <Nav>Payments</Nav>
          </Section>
        </Container>
      </Card>
    );
  }
}
