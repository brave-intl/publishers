import * as React from "react";

import {
  Container,
  HeaderLink,
  HeaderText,
  Link,
  Navigation,
  Wrapper
} from "./HeaderStyle";

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
          <Navigation>
            <Link href={Routes.payments.invoice.path}>
              {locale.payments.header.navigation.invoices}
            </Link>
            <Link href={Routes.payments.reports.path}>
              {locale.payments.header.navigation.reports}
            </Link>
          </Navigation>
        </Container>
      </Wrapper>
    );
  }
}
