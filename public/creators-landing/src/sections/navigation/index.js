import React from "react"
import { Box, Image, ResponsiveContext, Menu, Anchor } from "grommet"
import { MenuIcon, SecondaryButton } from "../../components"
import logo from "../../components/img/brave-rewards-creators-logo.svg"
import mobileLogo from "../../components/img/brave-rewards-logo.svg"
import batPill from "../../components/img/built-with-bat-pill.svg"

import locale from "../../locale/en"

const MobileNav = () => (
  <Box
    as="nav"
    direction="row"
    justify="between"
    align="center"
    pad="large"
    width="100%"
    id="nav"
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
  </Box>
)

const DefaultNav = () => (
  <Box
    as="nav"
    direction="row"
    justify="between"
    align="center"
    pad={{ vertical: "medium", horizontal: "large" }}
    width="100%"
    role="navigation"
    id="nav"
  >
    <Box direction="row" gap="medium" align="center">
      <Box as="a" href={locale.nav.logoHref}>
        <Image src={logo} height="32px" />
      </Box>
      <Box as="a" href={locale.nav.batPillHref}>
        <Image src={batPill} height="28px" />
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
  </Box>
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
