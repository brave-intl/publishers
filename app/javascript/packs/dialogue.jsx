import React from 'react'

import styled from 'styled-components'
import { Container } from '../packs/style.jsx'


export default class Dialogue extends React.Component {
  constructor(props) {
    super(props);
  }

  render(){
    return(
      <Container dialogue>
        This is a dialogue
      </Container>
    )
  }
}
