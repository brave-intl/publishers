import * as React from "react";

import {
  Container,
  HeaderLink,
  HeaderText,
  Link,
  Navigation,
  Wrapper
} from "./PaymentsHeaderStyle";

import locale from "../../../locale/en";
import Routes from "../../routes";

export default class Header extends React.Component {
  public render() {
    return (
      <Wrapper>
        <Container>
          <HeaderText>
            <HeaderLink href={Routes.payments.path}>
              {locale.payments.header.title}
            </HeaderLink>
          </HeaderText>
        </Container>
      </Wrapper>
    );
  }

  private isActive = path => {
    return window.location.href.indexOf(path) !== -1;
  };
}
