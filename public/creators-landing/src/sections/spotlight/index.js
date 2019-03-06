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
    margin={{ vertical: 'medium', horizontal: 'medium' }}
    direction='row'
    justify='center'
    id={props.backwards}
    className='carousel-container'
    wrap
  >
    <Box pad='large' align='center' justify='center' id='min' flex>
      <Heading level='3'>
        {props.quote}
        <Text as='p' color='grey'>
          {props.text}
        </Text>
      </Heading>
    </Box>
    <Box as='a' href={props.link} id='carousel-img' pad='medium'>
      <Image src={props.card} fit='contain' />
    </Box>
  </Box>
)

export const Spotlight = () => {
  return (
    <Box align='center' pad='large'>
      <Container align='center'>
        <Box height='32px' />
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
              link={locale.spotlight.baker_href}
              text={locale.spotlight.baker_credit}
              quote={locale.spotlight.baker_quote}
            />
            <Slide
              card={DefrancoCard}
              link={locale.spotlight.defranco_href}
              text={locale.spotlight.defranco_credit}
              quote={locale.spotlight.defranco_quote}
              backwards='row-reverse'
            />
            <Slide
              card={BobbyCard}
              link={locale.spotlight.bobby_href}
              text={locale.spotlight.bobby_credit}
              quote={locale.spotlight.bobby_quote}
            />
            <Slide
              card={CiccoCard}
              link={locale.spotlight.decicco_href}
              text={locale.spotlight.decicco_credit}
              quote={locale.spotlight.decicco_quote}
              backwards='row-reverse'
            />
          </Carousel>
        </Box>
        <Box height='40px' />
      </Container>
    </Box>
  )
}
