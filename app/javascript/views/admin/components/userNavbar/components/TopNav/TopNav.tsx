import * as React from "react";
import AvatarIcon from "./Avatar.svg";
import {
  Avatar,
  AvatarImage,
  Container,
  InnerContainer,
  Link,
  Name,
  Nav,
  Section,
  SectionGroup,
  Status,
  StatusLink
} from "./TopNavStyle";

import NavbarSelection from "../../UserNavbar";

import locale from "../../../../../../locale/en";
import routes from "../../../../../../routes/routes";

interface ITopNavProps {
  name: string;
  status: string;
  userID: string;
  avatar: string;
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
            <a href={`/admin/publishers/${this.props.userID}`}>
              {this.props.avatar ? (
                <Avatar>
                  <AvatarImage src={this.props.avatar} />
                </Avatar>
              ) : (
                <Avatar>
                  <AvatarImage src={AvatarIcon} />
                </Avatar>
              )}
            </a>
            <SectionGroup>
              <Section>
                <Name href={`/admin/publishers/${this.props.userID}`}>
                  {this.props.name}
                </Name>
                <StatusLink
                  href={`/admin/publishers/${
                    this.props.userID
                  }/publisher_status_updates`}
                >
                  <Status status={this.props.status}>
                    {this.props.status}
                  </Status>
                </StatusLink>
              </Section>
              <Link href={`/admin/publishers/${this.props.userID}/edit`}>
                Settings
              </Link>
              <Link>|</Link>
              <Link href={`/admin/security/${this.props.userID}`}>
                Security
              </Link>
              <Link>|</Link>
              <Link href={`/admin/channel_transfers/${this.props.userID}`}>
                Transfers
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
        selected={props.navbarSelection === "Dashboard"}
      >
        {locale.navbar.dashboard}
      </Nav>
      <Nav
        style={{ opacity: 0.5 }}
        selected={props.navbarSelection === "Channels"}
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
        selected={props.navbarSelection === "Referrals"}
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
        selected={props.navbarSelection === "Payments"}
      >
        {locale.navbar.payments}
      </Nav>
    </React.Fragment>
  );
}
