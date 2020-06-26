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

import Modal, { ModalSize } from "../../../../../../components/modal/Modal";
import NavbarSelection from "../../UserNavbar";

import locale from "../../../../../../locale/en";
import routes from "../../../../../../routes/routes";
import SimpleDialog from "../../../../../dialogs/SimpleDialog";

interface ITopNavProps {
  name: string;
  status: string;
  userID: string;
  avatar: string;
  navbarSelection: string;
  isOpen?: boolean;
  loginUrl?: string;
}

interface ITopNavState {
  isOpen: boolean;
  loginUrl: string;
}

export default class Referrals extends React.Component<ITopNavProps, ITopNavState> {
  constructor(props) {
    super(props);
    this.state = {isOpen: false, loginUrl: ""} ;
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
                    {this.props.status || "active"}
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
              <Link>|</Link>
              <Link
                id="sign_in_as_user_button"
                onClick={this.modalClick}
                href="#"
                className="mr-4"
              >
                Generate sign in link
              </Link>
              <Modal
                show={this.state.isOpen}
                size={ModalSize.Medium}
                handleClose={() =>
                  this.closeModal()
                }
                padding={false}
              >
                  <SimpleDialog
                    header="Copy below"
                    label={this.state.loginUrl}
                  />
              </Modal>
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

  private closeModal = () => {
    this.setState({ isOpen: false });
  }

  private modalClick = async () => {
    const url = "/admin/publishers/" + this.props.userID + "/sign_in_as_user";
    const options = {
      credentials: "same-origin",
      headers: {
        Accept: "text/html",
        "X-CSRF-Token": document.head.querySelector("[name=csrf-token]").getAttribute('content') as string,
        "X-Requested-With": "XMLHttpRequest",
      },
      method: "GET"
    } as RequestInit;
    const response = await fetch(url, options);
    const data = await response.json();
    this.setState({ loginUrl: data['login_url']});
    this.setState({ isOpen: !this.props.isOpen });
  };
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
