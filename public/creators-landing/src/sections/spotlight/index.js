import React from 'react'
import { Box, Heading, Text, Carousel, Image } from 'grommet'
import { Container } from '../../components'
import BakerCard from '../../components/img/card-baker.png'
import CiccoCard from '../../components/img/card-decicco.png'
import BobbyCard from '../../components/img/card-bobby.png'
import DefrancoCard from '../../components/img/card-defranco.png'
import locale from '../../locale/en'

const Slide = props => (
  <Box
    margin={{ horizontal: 'medium' }}
    direction='row'
    justify='center'
    id={props.backwards}
    className='carousel-container'
    wrap
  >
    <Box
      pad={{ horizontal: 'large' }}
      align='center'
      justify='center'
      id='min'
      flex
    >
      <Heading level='3'>
        {props.quote}
        <Text as='p' color='grey'>
          {props.text}
        </Text>
      </Heading>
    </Box>
    <Box
      as='a'
      href={props.link}
      id='carousel-img'
      pad='medium'
      className='carousel-height'
    >
      <Image src={props.card} fit='contain' />
    </Box>
  </Box>
)

export const Spotlight = () => {
  return (
    <Box align='center' pad='large'>
      <Container align='center'>
        <Box align='center' pad='medium'>
          <Heading level='3' textAlign='center'>
            {locale.spotlight.heading}
          </Heading>
          <Text as='p' textAlign='center' color='grey'>
            {locale.spotlight.subhead}
          </Text>
        </Box>
        <Box width='100%'>
          <Carousel play={9000}>
            <Slide
              card={BakerCard}
              link={locale.spotlight.bakerHref}
              text={locale.spotlight.bakerCredit}
              quote={locale.spotlight.bakerQuote}
            />
            <Slide
              card={DefrancoCard}
              link={locale.spotlight.defrancoHref}
              text={locale.spotlight.defrancoCredit}
              quote={locale.spotlight.defrancoQuote}
              backwards='row-reverse'
            />
            <Slide
              card={BobbyCard}
              link={locale.spotlight.bobbyHref}
              text={locale.spotlight.bobbyCredit}
              quote={locale.spotlight.bobbyQuote}
            />
            <Slide
              card={CiccoCard}
              link={locale.spotlight.deciccoHref}
              text={locale.spotlight.deciccoCredit}
              quote={locale.spotlight.deciccoQuote}
              backwards='row-reverse'
            />
          </Carousel>
        </Box>
      </Container>
    </Box>
  )
}
