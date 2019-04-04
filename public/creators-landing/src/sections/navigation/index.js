import React from "react";
import { Box, Image, ResponsiveContext, Anchor } from "grommet";
import { Link } from "react-router-dom";
import { SecondaryButton } from "../../components";
import logo from "../../components/img/brave-rewards-creators-logo.svg";
import batPill from "../../components/img/built-with-bat-pill.svg";

import locale from "../../locale/en";
import { NavWrapper, NavContainer } from "../../components/styled/container";
import MobileNav from "./mobileNav";

const DefaultNav = () => (
  <NavWrapper as="nav" id="nav">
    <NavContainer
      direction="row"
      justify="between"
      align="center"
      pad={{ vertical: "medium", horizontal: "large" }}
      width="100%"
      role="navigation"
    >
      <Box direction="row" gap="medium" align="center">
        <Link to={locale.nav.logoHref}>
          <Box as="span">
            <Image src={logo} height="32px" />
          </Box>
        </Link>
        <Box as="a" href={locale.nav.batPillHref}>
          <Image src={batPill} height="24px" />
        </Box>
      </Box>
      <Box direction="row" align="center" gap="large">
        <Link to={locale.nav.signupHref}>
          <Anchor
            as="span"
            a11yTitle="Sign up to be a Brave Rewards Creator"
            color="white"
            label={locale.nav.signup}
          />
        </Link>
        <Link to={locale.nav.loginHref}>
          <SecondaryButton
            a11yTitle="Log in to your Brave Creator dashboard"
            label={locale.nav.login}
            primary
          />
        </Link>
      </Box>
    </NavContainer>
  </NavWrapper>
);

export const Nav = () => {
  return (
    <ResponsiveContext.Consumer>
      {size => {
        if (size >= "medium") {
          return <MobileNav />;
        } else {
          return <DefaultNav />;
        }
      }}
    </ResponsiveContext.Consumer>
  );
};
