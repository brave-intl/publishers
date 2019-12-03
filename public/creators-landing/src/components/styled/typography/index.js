import styled from 'styled-components'
import { Heading, Anchor, Text } from 'grommet'

export const H2 = styled(Heading)`
  font-weight: 400;
`

export const SummaryNumber = styled(Heading)`
  line-height: 70px;
  font-size: 66px;
`

export const FooterLegal = styled(Anchor)`
  color: #7c7d8c;
  font-size: 12px;
`

export const CardButtonText = styled(Text)``
// can't get hover underline to not inherit
