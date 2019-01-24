import * as React from "react";

import { Button, Container, Text, Wrapper } from "./style";

import locale from "../../../locale/en";

export default class ReferralsNav extends React.Component {
  public render() {
    return (
      <Wrapper>
        <Container>
          <Text header>{locale.referrals}</Text>
          <Button>{locale.createCode}</Button>
        </Container>
      </Wrapper>
    );
  }
}
