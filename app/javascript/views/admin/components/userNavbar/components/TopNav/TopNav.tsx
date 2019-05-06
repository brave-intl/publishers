import * as React from "react";
import {
  Avatar,
  Container,
  InnerContainer,
  Name,
  Nav,
  Section,
  Status
} from "./TopNavStyle";

export default class Referrals extends React.Component<{}, {}> {
  constructor(props) {
    super(props);
    this.state = {};
  }

  public render() {
    return (
      <Container>
        <InnerContainer>
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
        </InnerContainer>
      </Container>
    );
  }
}
