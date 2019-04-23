import React from 'react'
import { Box, Heading, Image, ResponsiveContext } from 'grommet'
import { Container, PrimaryButton } from '../../components'
import CreatorsWide from '../../components/img/creator-logos-wide.webp'
import CreatorsMobile from '../../components/img/creator-logos-mobile.webp'
import locale from '../../locale/en'

export const Signoff = () => {
  return (
    <Box align='center'>
      <Container align='center' pad='large'>
        <Box pad={{ horizontal: 'large' }}>
          <Heading alignSelf='center' level='4' textAlign='center'>
            {locale.signoff.headlineOne}
            <strong>28,000</strong>
            {locale.signoff.headlineTwo}
          </Heading>
          <ResponsiveContext.Consumer>
            {size => {
              if (size >= 'medium') {
                return (
                  <Box pad='24px' id='signoff'>
                    <Image src={CreatorsMobile} fit='contain' />
                  </Box>
                )
              } else {
                return (
                  <Box pad={{ horizontal: 'large' }}>
                    <Image src={CreatorsWide} fit='contain' />
                  </Box>
                )
              }
            }}
          </ResponsiveContext.Consumer>
        </Box>
        <PrimaryButton
          label={locale.signoff.btn}
          margin='large'
          href={locale.signoff.btnHref}
          name={locale.signoff.btn}
        />
      </Container>
    </Box>
  )
}
