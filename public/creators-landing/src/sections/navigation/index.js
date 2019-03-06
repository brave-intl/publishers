import React from 'react'
import { Box, Image, ResponsiveContext, Menu, Anchor } from 'grommet'
import { MenuIcon, SecondaryButton } from '../../components'
import logo from '../../components/img/brave-rewards-creators-logo.svg'
import mobileLogo from '../../components/img/brave-rewards-logo.svg'
import locale from '../../locale/en'

const MobileNav = () => (
  <Box
    as='nav'
    direction='row'
    justify='between'
    align='center'
    pad='large'
    width='100%'
    id='nav'
  >
    <Box as='a' href={locale.nav.logo_href} a11yTitle='Brave Rewards Home Logo'>
      <Image
        a11yTitle='Brave Rewards Creator Logo'
        src={mobileLogo}
        height='36px'
      />
    </Box>
    <Menu
      icon={<MenuIcon />}
      a11yTitle='Nav'
      dropAlign={{ right: 'right', top: 'bottom' }}
      items={[
        { label: 'sign up', href: '/sign-up' },
        { label: 'log in', href: '/sign-in' }
      ]}
    />
  </Box>
)

const DefaultNav = () => (
  <Box
    as='nav'
    direction='row'
    justify='between'
    align='center'
    pad={{ vertical: 'medium', horizontal: 'large' }}
    width='100%'
    role='navigation'
    id='nav'
  >
    <Box
      as='a'
      href={locale.nav.logo_href}
      a11yTitle='Brave Rewards Home Button'
    >
      <Image a11yTitle='Brave Rewards Creator Logo' src={logo} height='32px' />
    </Box>
    <Box direction='row' align='center' gap='large'>
      <Anchor
        as='a'
        a11yTitle='Sign up to be a Brave Rewards Creator'
        href={locale.nav.signup_href}
        color='white'
        label={locale.nav.signup}
      />
      <SecondaryButton
        a11yTitle='Log in to your Brave Creator dashboard'
        href={locale.nav.login_href}
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
        if (size === 'small') {
          return <MobileNav />
        } else {
          return <DefaultNav />
        }
      }}
    </ResponsiveContext.Consumer>
  )
}
