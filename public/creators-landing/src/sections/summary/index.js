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
              margin={{ vertical: 'medium' }}
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
                  {props.description_link}
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
              margin={{ vertical: 'medium' }}
            >
              <SummaryNumber level='1' color='white' margin='0' size='large'>
                {props.step}
              </SummaryNumber>
              <Box>
                <Heading level='3' color='white' margin='0'>
                  {props.title}
                </Heading>
                <Paragraph size='small' color='white'>
                  {props.description}
                  {props.description_link}
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
          title={locale.summary.one_title}
          description={locale.summary.one_desc}
        />
        <TextBlock
          side='end'
          step='2'
          title={locale.summary.two_title}
          description={locale.summary.two_desc}
        />
        <TextBlock
          side='start'
          step='3'
          title={locale.summary.three_title}
          description={locale.summary.three_desc}
        />
        <TextBlock
          side='end'
          step='4'
          title={locale.summary.four_title}
          description={locale.summary.four_desc}
          description_link={
            <Anchor
              href={locale.summary.four_link_href}
              label={locale.summary.four_link}
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
            href={locale.summary.card_business_href}
            icon={<ChatIcon />}
            title={locale.summary.card_business}
          />
          <CardButton
            href={locale.summary.card_help_href}
            icon={<HelpIcon />}
            title={locale.summary.card_help}
          />
          <CardButton
            href={locale.summary.card_gen_href}
            icon={<MailIcon />}
            title={locale.summary.card_gen}
          />
        </Box>
      </Container>
      <Box height='180px' />
      <SwoopBottom />
    </GradientBackground>
  )
}
