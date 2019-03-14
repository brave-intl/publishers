import * as React from "react";

import OutsideAlerter from "../outsideAlerter/OutsideAlerter";

import { CaratDownIcon } from "brave-ui/components/icons";
import CreatorsLogo from "../../../assets/images/logo_br_creators.png";
import locale from "../../locale/en";
import routes from "../../routes/routes";

import {
  AvatarContainer,
  Container,
  DropdownGroup,
  DropdownItem,
  DropdownMenu,
  DropdownToggle,
  Logo,
  Name,
  Nav,
  NavGroup,
  Wrapper
} from "./NavbarStyle";

export enum NavbarSelection {
  Dashboard,
  Channels,
  Referrals,
  Payments
}

interface INavbarProps {
  name: string;
  navbarSelection: NavbarSelection;
}
interface INavbarState {
  menuOpen: boolean;
}

const outsideAlerterStyle = {
  marginBottom: "auto",
  marginLeft: "auto",
  marginTop: "auto",
  minWidth: "125px"
};

export class Navbar extends React.Component<INavbarProps, INavbarState> {
  constructor(props) {
    super(props);
    this.state = {
      menuOpen: false
    };
  }

  public toggleMenu = () => {
    this.setState(prevState => ({
      menuOpen: !prevState.menuOpen
    }));
  };

  public closeMenu = () => {
    this.setState({
      menuOpen: false
    });
  };

  public render() {
    return (
      <Wrapper>
        <Container>
          <BraveLogo />
          <Navigation navbarSelection={this.props.navbarSelection} />
          <OutsideAlerter
            onOutsideClick={this.closeMenu}
            outsideAlerterStyle={outsideAlerterStyle}
          >
            <DropdownGroup onClick={this.toggleMenu}>
              <Dropdown menuOpen={this.state.menuOpen} />
              <AvatarContainer>
                <AvatarIcon />
              </AvatarContainer>
              <Name>{this.props.name}</Name>
              <DropdownToggle>
                <CaratDownIcon height={25} width={25} />
              </DropdownToggle>
            </DropdownGroup>
          </OutsideAlerter>
        </Container>
      </Wrapper>
    );
  }
}

function Navigation(props) {
  return (
    <NavGroup>
      <Nav
        onClick={() => (window.location.href = routes.navbar.dashboard.path)}
        selected={props.navbarSelection === NavbarSelection.Dashboard}
      >
        {locale.navbar.dashboard}
      </Nav>
      {/* <Nav selected={props.navbarSelection === NavbarSelection.Channels}>
        {locale.navbar.channels}
      </Nav> */}
      <Nav
        onClick={() => (window.location.href = routes.navbar.referrals.path)}
        selected={props.navbarSelection === NavbarSelection.Referrals}
      >
        {locale.navbar.referrals}
      </Nav>
      <Nav
        onClick={() => (window.location.href = routes.navbar.payments.path)}
        selected={props.navbarSelection === NavbarSelection.Payments}
      >
        {locale.navbar.payments}
      </Nav>
    </NavGroup>
  );
}

function Dropdown(props) {
  return (
    <DropdownMenu open={props.menuOpen}>
      <DropdownItem
        onClick={() => (window.location.href = routes.navbar.security.path)}
      >
        {locale.navbar.security}
      </DropdownItem>
      <DropdownItem
        onClick={() => (window.location.href = routes.navbar.help.path)}
      >
        {locale.navbar.help}
      </DropdownItem>
      <DropdownItem
        onClick={() => (window.location.href = routes.navbar.logOut.path)}
      >
        {locale.navbar.logOut}
      </DropdownItem>
    </DropdownMenu>
  );
}

// Todo - Move this to external .svg file
function AvatarIcon() {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="34"
      height="34"
      viewBox="0 0 42 42"
    >
      <path
        fill="#B9C2C5"
        fill-rule="evenodd"
        d="M32.5641581,50.1111111 L10.9678951,49.6856995 C10.8065017,49.6856995 8.79522693,37.7381475 8.65407097,37.3765451 C8.55541357,37.1247514 8.56047293,36.7805141 8.57818066,36.0506697 C8.60044182,35.0961007 8.20480038,34.6900641 9.9927759,31.9703851 C11.6107571,30.4432789 12.8209545,30.3232555 14.8755579,29.285947 C17.0677758,28.1801995 18.2840444,27.520837 18.8441148,26.9860945 L20.0796089,25.8062901 L19.00652,24.4753072 C17.3161901,22.3782177 16.3453001,20.0625323 16.3453001,18.1222392 C16.3453001,16.6262881 16.3453001,14.9316599 17.0465265,13.5281523 C17.8868851,11.8503785 19.5665905,11 22.0441559,11 C24.5212153,11 26.2029444,11.8503785 27.0422912,13.5276416 C27.7435176,14.9316599 27.7435176,16.6262881 27.7435176,18.1222392 C27.7435176,20.0620215 26.7731336,22.3777069 25.0807798,24.4753072 L24.007185,25.8073115 L25.2441969,26.9860945 C25.8032555,27.5198155 26.9001233,28.7547796 29.2122479,29.285947 C31.4515177,29.80026 32.6930831,31.0505462 33.3305616,31.7533215 C34.4061802,32.9377225 35.3968016,34.8999773 35.4347467,36.0251328 C35.4504307,36.4847969 35.4504307,36.8515066 35.4094499,37.3765451 C35.385671,37.5568356 32.7088556,49.8823006 32.5641581,50.1111111 Z"
        transform="translate(-1 -1)"
      />
    </svg>
  );
}

function BraveLogo() {
  return (
    <Logo
      onClick={() => (window.location.href = routes.navbar.dashboard.path)}
      src={CreatorsLogo}
    />
  );
}
