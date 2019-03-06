import React from 'react'
import { Nav } from '../sections'
import { theme } from '../theme'
import { Grommet } from 'grommet'
import { MainSignUp } from '../sections/main-section'

export const SignUp = () => {
  return (
    <Grommet theme={theme}>
      <Nav />
      <MainSignUp />
    </Grommet>
  )
}
