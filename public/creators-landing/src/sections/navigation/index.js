import React from "react"
import { Box, Image, ResponsiveContext, Menu, Anchor } from "grommet"
import { MenuIcon, SecondaryButton } from "../../components"
import logo from "../../components/img/brave-rewards-creators-logo.svg"
import mobileLogo from "../../components/img/brave-rewards-creators-mobile-logo.svg"
import batPill from "../../components/img/built-with-bat-pill.svg"

import locale from "../../locale/en"
import { NavWrapper, NavContainer } from "../../components/styled/container";

const MobileNav = () => (
  <NavWrapper
    as="nav"
    id="nav"
  >
    <NavContainer
      direction="row"
      justify="between"
      align="center"
      pad={{ vertical: "medium", horizontal: "large" }}
      width="100%"
      role="navigation"
    >
      <Box as="a" href={locale.nav.logoHref}>
        <Image src={mobileLogo} height="36px" />
      </Box>
      <Menu
        icon={<MenuIcon />}
        a11yTitle="Nav"
        dropAlign={{ right: "right", top: "bottom" }}
        items={[
          { label: "sign up", href: "/sign-up" },
          { label: "log in", href: "/log-in" }
        ]}
      />
    </NavContainer>
  </NavWrapper>
)



const DefaultNav = () => (
  <NavWrapper
    as="nav"
    id="nav"
  >
    <NavContainer
      direction="row"
      justify="between"
      align="center"
      pad={{ vertical: "medium", horizontal: "large" }}
      width="100%"
      role="navigation"
    >
      <Box direction="row" gap="medium" align="center">
        <Box as="a" href={locale.nav.logoHref}>
          <Image src={logo} height="32px" />
        </Box>
        <Box as="a" href={locale.nav.batPillHref}>
          <Image src={batPill} height="24px" />
        </Box>
      </Box>
      <Box direction="row" align="center" gap="large">
        <Anchor
          as="a"
          a11yTitle="Sign up to be a Brave Rewards Creator"
          href={locale.nav.signupHref}
          color="white"
          label={locale.nav.signup}
        />
        <SecondaryButton
          a11yTitle="Log in to your Brave Creator dashboard"
          href={locale.nav.loginHref}
          label={locale.nav.login}
          primary
        />
      </Box>
    </NavContainer>
  </NavWrapper >
)

export const Nav = () => {
  return (
    <ResponsiveContext.Consumer>
      {size => {
        if (size >= "medium") {
          return <MobileNav />
        } else {
          return <DefaultNav />
        }
      }}
    </ResponsiveContext.Consumer>
  )
}
