import React from 'react'
import { Box, Text, Image, ResponsiveContext } from 'grommet'
import { FooterLegal } from '../../components'
import BuiltWithBat from '../../components/img/built-with-bat.svg'

const FooterComponent = props => (
  <Box
    justify='between'
    direction={props.direction}
    align='center'
    pad={{ vertical: 'medium', horizontal: 'large' }}
    background='#F3F3FD'
    wrap
  >
    <Box direction='row' gap='small' pad={props.padded}>
      <FooterLegal
        label='© Brave Software'
        href='http://www.brave.com'
        a11yTitle='Brave Browser Link'
      />
      <Text color='grey' size='small'>
        |
      </Text>
      <FooterLegal
        label='Privacy Policy'
        href='https://brave.com/publishers-creators-privacy'
      />
      <Text color='grey' size='small'>
        |
      </Text>
      <FooterLegal
        label='Terms of Use'
        href='https://basicattentiontoken.org/publisher-terms-of-service/'
      />
    </Box>
    <Box
      as='a'
      direction='row'
      href='https://basicattentiontoken.org'
      pad={props.padded}
    >
      <Image src={BuiltWithBat} />
    </Box>
  </Box>
)

export const Footer = () => {
  return (
    <ResponsiveContext.Consumer>
      {size => {
        if (size === 'small') {
          return <FooterComponent direction='column' padded='8px' />
        } else {
          return <FooterComponent direction='row' />
        }
      }}
    </ResponsiveContext.Consumer>
  )
}
