import React from "react";
import { Box, Image, Menu } from "grommet";
import { Link, withRouter } from "react-router-dom";
import locale from "../../../locale/en";
import mobileLogo from "../../../components/img/brave-rewards-creators-mobile-logo.svg";
import { MenuIcon } from "../../../components";
import { NavWrapper, NavContainer } from "../../../components/styled/container";

const MobileNav = props => (
  <NavWrapper as="nav" id="nav">
    <NavContainer
      direction="row"
      justify="between"
      align="center"
      pad={{ vertical: "medium", horizontal: "large" }}
      width="100%"
      role="navigation"
    >
      <Link to={locale.nav.logoHref}>
        <Box as="span">
          <Image src={mobileLogo} height="36px" />
        </Box>
      </Link>
      <Menu
        icon={<MenuIcon />}
        a11yTitle="Nav"
        dropAlign={{ right: "right", top: "bottom" }}
        items={[
          {
            label: "sign up",
            onClick: () => {
              props.history.push("/sign-up");
            }
          },
          {
            label: "log in",
            onClick: () => {
              props.history.push("/log-in");
            }
          }
        ]}
      />
    </NavContainer>
  </NavWrapper>
);

export default withRouter(MobileNav);
