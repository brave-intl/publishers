import React from "react";
import { Box, Image, ResponsiveContext, Anchor } from "grommet";
import { Link } from "react-router-dom";
import { SecondaryButton } from "../../components";
import logo from "../../components/img/brave-rewards-creators-logo.svg";
import batPill from "../../components/img/built-with-bat-pill.svg";

import locale from "../../locale/en";
import { NavWrapper, NavContainer } from "../../components/styled/container";
import MobileNav from "./mobileNav";
import { FormattedMessage } from 'react-intl';

const logAction = (action, value) => {
  if (window._paq) {
    window._paq.push(["trackEvent", action, "Clicked", value]);
  }
};

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
        <Link to={locale.nav.logoHref} name="Home">
          <Box as="span">
            <Image src={logo} height="32px" alt={<FormattedMessage id="nav.logoAlt"/>} />
          </Box>
        </Link>
        <Box
          as="a"
          href={locale.nav.batPillHref}
          name={<FormattedMessage id="nav.batPillHref"/>}
          aria-label={<FormattedMessage id="nav.batPillAlt"/>}
        >
          <Image src={batPill} height="24px" alt={<FormattedMessage id="nav.batPillAlt"/>} />
        </Box>
      </Box>
      <Box direction="row" align="center" gap="large">
        <Link
          to={locale.nav.signupHref}
          onClick={() => logAction("LandingSignUpClicked", "Landing")}
        >
          <Anchor
            as="span"
            a11yTitle="Sign up to be a Brave Rewards Creator"
            color="white"
            label={<FormattedMessage id="nav.signup"/>}
            name={<FormattedMessage id="nav.signup"/>}
          />
        </Link>
        <Link
          to={locale.nav.loginHref}
          onClick={() => logAction("LandingLoginClicked", "Landing")}
        >
          <SecondaryButton
            a11yTitle="Log in to your Brave Creator dashboard"
            label={<FormattedMessage id="nav.login"/>}
            name={<FormattedMessage id="nav.login"/>}
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
