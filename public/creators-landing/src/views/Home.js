import React from 'react'
import { MainHome, Spotlight, Summary, Signoff, Footer, Nav } from '../sections'
import { theme } from '../theme'
import { Grommet } from 'grommet'

export const Home = () => {
  return (
    <Grommet theme={theme}>
      <Nav />
      <MainHome />
      <Spotlight />
      <Summary />
      <Signoff />
      <Footer />
    </Grommet>
  )
}
