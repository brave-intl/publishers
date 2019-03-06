import React from 'react'
import {
  Container,
  GradientBackground,
  H2,
  PrimaryButton,
  UserIcon,
  YouTubeIcon,
  PublicationIcon,
  TwitchIcon,
  SwoopBottom,
  StyledInput
} from '../../components'
import { Heading, Text, Box, Anchor } from 'grommet'
import locale from '../../locale/en'

export const MainHome = () => {
  return (
    <GradientBackground align='center'>
      <Container animation='fadeIn' role='main'>
        <Box
          direction='column'
          pad='large'
          margin={{ top: '80px', bottom: '60px' }}
        >
          <Heading
            level='1'
            color='white'
            margin={{ vertical: 'small' }}
            a11yTitle='Headline'
          >
            {locale.main.home.headline}
          </Heading>
          <H2 level='2' size='small' color='#E9E9F4' a11yTitle='Subtitle'>
            {locale.main.home.subhead}
          </H2>
          <Heading level='3' size='small' color='#E9E9F4'>
            {locale.main.home.examples.headline}
          </Heading>
          <Box direction='row-responsive' gap='24px'>
            <Box direction='column'>
              <Box direction='row' gap='small' margin={{ vertical: '8px' }}>
                <UserIcon />
                <Heading level='3' color='#E9E9F4' size='small' margin='0'>
                  {locale.main.home.examples.website}
                </Heading>
              </Box>
              <Box direction='row' gap='small' margin={{ vertical: '8px' }}>
                <YouTubeIcon />
                <Heading level='3' color='#E9E9F4' size='small' margin='0'>
                  {locale.main.home.examples.youtube}
                </Heading>
              </Box>
            </Box>
            <Box direction='column'>
              <Box direction='row' gap='small' margin={{ vertical: '8px' }}>
                <PublicationIcon />
                <Heading level='3' color='#E9E9F4' size='small' margin='0'>
                  {locale.main.home.examples.publication}
                </Heading>
              </Box>
              <Box direction='row' gap='small' margin={{ vertical: '8px' }}>
                <TwitchIcon />
                <Heading level='3' color='#E9E9F4' size='small' margin='0'>
                  {locale.main.home.examples.Twitch}
                </Heading>
              </Box>
            </Box>
          </Box>
          <Box direction='row' pad={{ vertical: '24px' }} width='100%'>
            <PrimaryButton
              label={locale.main.home.btn.signup}
              a11yTitle='Sign up'
            />
          </Box>
        </Box>
      </Container>
      <SwoopBottom />
    </GradientBackground>
  )
}

// Sign up and sign in shared this component since
// they are so similar in structure
const SignComponent = props => {
  return (
    <GradientBackground height='100vh' align='center'>
      <Container
        animation='fadeIn'
        role='main'
        justify='center'
        align='center'
        pad='large'
        id='zindex'
        fill
      >
        <Box width='540px' align='center'>
          <Heading
            level='3'
            color='white'
            a11yTitle='Headline'
            textAlign='center'
            margin='small'
          >
            {props.heading}
          </Heading>
          <Text
            size='16px'
            color='rgba(255, 255, 255, .8)'
            textAlign='center'
            margin={{ bottom: '52px' }}
          >
            {props.subhead}
          </Text>
          <Box width='100%' margin={{ bottom: '32px' }}>
            <StyledInput size='large' placeholder={props.input_placeholder} />
          </Box>
          <PrimaryButton
            label={props.btn}
            a11yTitle={props.btn}
            margin={{ bottom: '30px' }}
          />
          <Anchor
            href={props.tiny_1_href}
            label={props.tiny_1}
            color='rgba(255, 255, 255, .8)'
            size='xsmall'
          />
          <Anchor
            href={props.tiny_2_href}
            label={props.tiny_2}
            color='rgba(255, 255, 255, .8)'
            size='xsmall'
          />
          <Box height='100px' />
        </Box>
        <Box direction='row' gap='small' align='center' id='terms-help'>
          <Anchor
            label={props.footer_1}
            href={props.footer_1_href}
            color='rgba(255, 255, 255, .8)'
            size='small'
          />
          <Text>|</Text>
          <Anchor
            label={props.footer_2}
            href={props.footer_2_href}
            color='rgba(255, 255, 255, .8)'
            size='small'
          />
        </Box>
      </Container>
      <SwoopBottom swoop='fade' />
    </GradientBackground>
  )
}

export const MainSignIn = () => {
  return (
    <SignComponent
      heading={locale.main.signin.heading}
      subhead={locale.main.signin.subhead}
      input_placeholder={locale.main.signin.input_placeholder}
      btn={locale.main.signin.btn}
      tiny_1={locale.main.signin.tiny_1}
      tiny_1_href={locale.main.signin.tiny_1_href}
      tiny_2={locale.main.signin.tiny_2}
      tiny_2_href={locale.main.signin.tiny_2_href}
      footer_1={locale.main.footer_1}
      footer_1_href={locale.main.footer_1_href}
      footer_2={locale.main.footer_2}
      footer_2_href={locale.main.footer_2_href}
    />
  )
}

export const MainSignUp = () => {
  return (
    <SignComponent
      heading={locale.main.signup.heading}
      subhead={locale.main.signup.subhead}
      input_placeholder={locale.main.signup.input_placeholder}
      btn={locale.main.signup.btn}
      tiny_1={locale.main.signup.tiny_1}
      tiny_1_href={locale.main.signup.tiny_1_href}
      footer_1={locale.main.footer_1}
      footer_1_href={locale.main.footer_1_href}
      footer_2={locale.main.footer_2}
      footer_2_href={locale.main.footer_2_href}
    />
  )
}
