import React from 'react'
import {
  Container,
  GradientBackground,
  SummaryNumber,
  SummaryContainer,
  DividerLine,
  CardButtonContainer,
  CardButtonText,
  CaratRightIcon,
  ChatIcon,
  HelpIcon,
  MailIcon,
  CardButtonAnchor,
  SwoopBottom,
  SwoopTop,
  IconContainer
} from '../../components'
import { Heading, Box, Anchor, Paragraph, ResponsiveContext } from 'grommet'
import locale from '../../locale/en'

const TextBlock = props => {
  return (
    <ResponsiveContext.Consumer>
      {size => {
        if (size >= 'medium') {
          return (
            <SummaryContainer
              direction='row'
              alignSelf={props.side}
              gap='12px'
              width='100%'
              pad='medium'
            >
              <SummaryNumber level='1' color='white' margin='0' size='large'>
                {props.step}
              </SummaryNumber>
              <Box>
                <Heading level='3' color='white' margin='0'>
                  {props.title}
                </Heading>
                <Paragraph color='#E9E9F4' width='100%'>
                  {props.description}
                  {props.descriptionLink}
                </Paragraph>
              </Box>
            </SummaryContainer>
          )
        } else {
          return (
            <SummaryContainer
              direction='row'
              width='50%'
              alignSelf={props.side}
              gap='16px'
              pad='medium'
            >
              <SummaryNumber level='1' color='white' margin='0' size='large'>
                {props.step}
              </SummaryNumber>
              <Box width='480px'>
                <Heading level='3' color='white' margin='0'>
                  {props.title}
                </Heading>
                <Paragraph size='small' color='white'>
                  {props.description}
                  {props.descriptionLink}
                </Paragraph>
              </Box>
            </SummaryContainer>
          )
        }
      }}
    </ResponsiveContext.Consumer>
  )
}

const CardButton = props => {
  return (
    <CardButtonAnchor href={props.href}>
      <CardButtonContainer
        direction='row'
        gap='16px'
        justify='center'
        align='center'
      >
        <IconContainer size='28px' fill='#FFF'>
          {props.icon}
        </IconContainer>
        <CardButtonText textAlign='start' color='white'>
          {props.title}
        </CardButtonText>
        <IconContainer size='24px' fill='#FFF'>
          <CaratRightIcon />
        </IconContainer>
      </CardButtonContainer>
    </CardButtonAnchor>
  )
}

export const Summary = () => {
  return (
    <GradientBackground align='center'>
      <SwoopTop />
      <Box height='160px' />
      <Container align='center' pad={{ horizontal: 'large' }} responsive>
        <Heading
          level='2'
          textAlign='center'
          color='white'
          margin={{ vertical: 'large' }}
        >
          {locale.summary.heading}
        </Heading>
        <TextBlock
          side='start'
          step='1'
          title={locale.summary.oneTitle}
          description={locale.summary.oneDesc}
        />
        <TextBlock
          side='end'
          step='2'
          title={locale.summary.twoTitle}
          description={locale.summary.twoDesc}
        />
        <TextBlock
          side='start'
          step='3'
          title={locale.summary.threeTitle}
          description={locale.summary.threeDesc}
        />
        <TextBlock
          side='end'
          step='4'
          title={locale.summary.fourTitle}
          description={locale.summary.fourDesc}
          description_link={
            <Anchor
              href={locale.summary.fourLinkHref}
              label={locale.summary.fourLink}
              color='white'
            />
          }
        />
        <DividerLine />
        <Box
          direction='row-responsive'
          gap='medium'
          margin={{ vertical: '24px' }}
          width='100%'
          justify='center'
        >
          <CardButton
            href={locale.summary.cardBusinessHref}
            icon={<ChatIcon />}
            title={locale.summary.cardBusiness}
          />
          <CardButton
            href={locale.summary.cardHelpHref}
            icon={<HelpIcon />}
            title={locale.summary.cardHelp}
          />
          <CardButton
            href={locale.summary.cardGenHref}
            icon={<MailIcon />}
            title={locale.summary.cardGen}
          />
        </Box>
      </Container>
      <Box height='180px' />
      <SwoopBottom />
    </GradientBackground>
  )
}
