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
  navbarSelection: NavbarSelection;
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
            <Name>{this.props.name}</Name>
            <Status status={this.props.status}>{this.props.status}</Status>
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
        onClick={() =>
          (window.location.href = routes.admin.userNavbar.referrals.path.replace(
            "{id}",
            props.userID
          ))
        }
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
