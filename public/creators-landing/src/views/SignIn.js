import React from 'react'
import { Nav } from '../sections'
import { theme } from '../theme'
import { Grommet } from 'grommet'
import { MainSignIn } from '../sections/main-section'

export const SignIn = () => {
  return (
    <Grommet theme={theme}>
      <Nav />
      <MainSignIn />
    </Grommet>
  )
}
