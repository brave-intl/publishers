import * as React from "react";
import {
  Avatar,
  Container,
  InnerContainer,
  Link,
  Name,
  Nav,
  Section,
  SectionGroup,
  Status
} from "./TopNavStyle";

import locale from "../../../../../../locale/en";
import routes from "../../../../../../routes/routes";

export enum NavbarSelection {
  Dashboard,
  Channels,
  Referrals,
  Payments
}

interface ITopNavProps {
  name: string;
  status: string;
  userID: string;
  navbarSelection: string;
}

export default class Referrals extends React.Component<ITopNavProps, {}> {
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
            <SectionGroup>
              <Section>
                <Name href={`/admin/publishers/${this.props.userID}`}>
                  {this.props.name}
                </Name>
                <Status status={this.props.status}>{this.props.status}</Status>
              </Section>
              <Link href={`/admin/publishers/${this.props.userID}/edit`}>
                Edit Settings
              </Link>
              <Link>|</Link>
              <Link href={`/admin/security/${this.props.userID}`}>
                Security
              </Link>
            </SectionGroup>
          </Section>
          <Section>
            <Navigation
              navbarSelection={this.props.navbarSelection}
              userID={this.props.userID}
            />
          </Section>
        </InnerContainer>
      </Container>
    );
  }
}

function Navigation(props) {
  return (
    <React.Fragment>
      <Nav
        onClick={() =>
          (window.location.href = routes.admin.userNavbar.dashboard.path.replace(
            "{id}",
            props.userID
          ))
        }
        selected={props.navbarSelection === NavbarSelection.Dashboard}
      >
        {locale.navbar.dashboard}
      </Nav>
      <Nav
        style={{ opacity: 0.5 }}
        selected={props.navbarSelection === NavbarSelection.Channels}
      >
        {locale.navbar.channels}
      </Nav>
      <Nav
        style={{ opacity: 0.5 }}
        selected={props.navbarSelection === NavbarSelection.Referrals}
      >
        {locale.navbar.referrals}
      </Nav>
      <Nav
        onClick={() =>
          (window.location.href = routes.admin.userNavbar.payments.path.replace(
            "{id}",
            props.userID
          ))
        }
        selected={props.navbarSelection === NavbarSelection.Payments}
      >
        {locale.navbar.payments}
      </Nav>
    </React.Fragment>
  );
}
