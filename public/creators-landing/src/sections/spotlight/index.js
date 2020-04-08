import React from "react";
import { Box, Heading, Text, Carousel, Image } from "grommet";
import { Container } from "../../components";
import BakerCard_webp from "../../components/img/card-baker.webp";
import BakerCard_png from "../../components/img/card-baker.png";
import DefrancoCard_webp from "../../components/img/card-defranco.webp";
import DefrancoCard_png from "../../components/img/card-defranco.png";
import ScottyCard_webp from "../../components/img/card-scotty.webp";
import ScottyCard_png from "../../components/img/card-scotty.png";
import locale from "../../locale/en";
import { FormattedMessage, useIntl } from 'react-intl';

const cardImages = {
  BakerCard: {
    webp: BakerCard_webp,
    default: BakerCard_png
  },
  DefrancoCard: {
    webp: DefrancoCard_webp,
    default: DefrancoCard_png
  },
  ScottyCard: {
    webp: ScottyCard_webp,
    default: ScottyCard_png
  }
};

const Slide = props => (
  <Box
    margin={{ horizontal: "medium" }}
    direction="row"
    justify="center"
    id={props.backwards}
    className="carousel-container"
    wrap
  >
    <Box
      pad={{ horizontal: "large" }}
      align="center"
      justify="center"
      className="carousel-quote"
      flex
    >
      <Heading level="3">
        {props.quote}
        <Text as="p" color="grey">
          {props.text}
        </Text>
      </Heading>
    </Box>
    <Box
      as="a"
      href={props.link}
      id="carousel-img"
      pad="medium"
      className="carousel-height"
    >
      <Image
        src={props.card.webp}
        fallback={props.card.default}
        fit="contain"
        alt={props.alt}
      />
    </Box>
  </Box>
);

export const Spotlight = () => {
  const intl = useIntl();

  const { ScottyCard, DefrancoCard, BakerCard } = cardImages;
  return (
    <Box align="center" pad="large">
      <Container align="center">
        <Box align="center" pad="medium">
          <Heading level="3" textAlign="center">
            {<FormattedMessage id="spotlight.heading"/>}
          </Heading>
          <Text as="p" textAlign="center" color="grey">
            {<FormattedMessage id="spotlight.subhead"/>}
          </Text>
        </Box>
        <Box width="100%">
          <Carousel play={9000}>
            <Slide
              card={ScottyCard}
              link={locale.spotlight.scottyHref}
              text={<FormattedMessage id="spotlight.scottyCredit"/>}
              quote={<FormattedMessage id="spotlight.scottyQuote"/>}
              alt={intl.formatMessage({ id: "spotlight.scottyAlt" })}
            />
            <Slide
              card={BakerCard}
              link={locale.spotlight.bakerHref}
              text={<FormattedMessage id="spotlight.bakerCredit"/>}
              quote={<FormattedMessage id="spotlight.bakerQuote"/>}
              alt={intl.formatMessage({ id: "spotlight.bakerAlt" })}
            />
            <Slide
              card={DefrancoCard}
              link={locale.spotlight.defrancoHref}
              text={<FormattedMessage id="spotlight.defrancoCredit"/>}
              quote={<FormattedMessage id="spotlight.defrancoQuote"/>}
              backwards="row-reverse"
              alt={intl.formatMessage({ id: "spotlight.defrancoAlt" })}
            />
          </Carousel>
        </Box>
      </Container>
    </Box>
  );
};
