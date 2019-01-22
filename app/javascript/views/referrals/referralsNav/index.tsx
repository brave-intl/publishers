import * as React from "react";

import { Wrapper, Container, Text, Button } from "./style";

import locale from "../../../locale/en";

export default class ReferralsNav extends React.Component {
  render() {
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
