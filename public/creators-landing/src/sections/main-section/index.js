import React from "react"
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
} from "../../components"
import batPill from "../../components/img/built-with-bat-pill.svg"
import { Heading, Text, Box, Anchor, Form, Image } from "grommet"
import locale from "../../locale/en"

export const MainHome = () => {
  return (
    <GradientBackground align="center">
      <Container animation="fadeIn" role="main">
        <Box
          direction="column"
          pad="large"
          margin={{ top: "80px", bottom: "90px" }}
        >
          <Box className="bat-pill" as="a" href={locale.nav.batPillHref}>
            <Image src={batPill} />
          </Box>
          <Heading level="1" color="white" margin={{ vertical: "small" }}>
            {locale.main.home.headline}
          </Heading>
          <H2 level="2" size="small" color="#E9E9F4">
            {locale.main.home.subhead}
          </H2>
          <Box direction="row" pad={{ vertical: "24px" }} width="100%">
            <PrimaryButton
              label={locale.main.home.btn.signup}
              href={locale.main.home.btn.signupHref}
            />
          </Box>
          <Heading level="3" size="small" color="#E9E9F4">
            {locale.main.home.examples.headline}
          </Heading>
          <Box direction="row-responsive" gap="24px">
            <Box direction="column">
              <Box direction="row" gap="small" margin={{ vertical: "8px" }}>
                <UserIcon />
                <Heading level="3" color="#E9E9F4" size="small" margin="0">
                  {locale.main.home.examples.website}
                </Heading>
              </Box>
              <Box direction="row" gap="small" margin={{ vertical: "8px" }}>
                <YouTubeIcon />
                <Heading level="3" color="#E9E9F4" size="small" margin="0">
                  {locale.main.home.examples.youtube}
                </Heading>
              </Box>
            </Box>
            <Box direction="column">
              <Box direction="row" gap="small" margin={{ vertical: "8px" }}>
                <PublicationIcon />
                <Heading level="3" color="#E9E9F4" size="small" margin="0">
                  {locale.main.home.examples.publication}
                </Heading>
              </Box>
              <Box direction="row" gap="small" margin={{ vertical: "8px" }}>
                <TwitchIcon />
                <Heading level="3" color="#E9E9F4" size="small" margin="0">
                  {locale.main.home.examples.Twitch}
                </Heading>
              </Box>
            </Box>
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
    <GradientBackground height="100vh" align="center">
      <Container
        animation="fadeIn"
        role="main"
        justify="center"
        align="center"
        pad="large"
        id="zindex"
        fill
      >
        <Box width="540px" align="center">
          <Heading
            level="3"
            color="white"
            a11yTitle="Headline"
            textAlign="center"
            margin="small"
          >
            {props.heading}
          </Heading>
          <Text
            size="16px"
            color="rgba(255, 255, 255, .8)"
            textAlign="center"
            margin={{ bottom: "50px" }}
          >
            {props.subhead}
          </Text>
          <Box width="100%" margin={{ bottom: "30px" }}>
            <Form
              className="email-input"
              messages={{
                required: "Please enter a valid email address."
              }}
              onSubmit={({ value }) => console.log("Submit", value)}
            >
              <StyledInput
                name="email"
                type="email"
                placeholder="Enter your email"
                required
              />
              <PrimaryButton
                label={props.btn}
                type="submit"
                alignSelf="center"
              />
            </Form>
          </Box>
          <Anchor
            href={props.tinyOneHref}
            label={props.tinyOne}
            color="rgba(255, 255, 255, .8)"
            size="xsmall"
          />
          <Anchor
            href={props.tinyTwoHref}
            label={props.tinyTwo}
            color="rgba(255, 255, 255, .8)"
            size="xsmall"
          />
          <Box height="100px" />
        </Box>
        <Box id="terms-help" gap="large">
          <Box direction="row" gap="small" align="center">
            <Anchor
              label={props.footerOne}
              href={props.footerOneHref}
              color="rgba(255, 255, 255, .8)"
              size="small"
            />
            <Text>|</Text>
            <Anchor
              label={props.footerTwo}
              href={props.footerTwoHref}
              color="rgba(255, 255, 255, .8)"
              size="small"
            />
          </Box>
          <Box as="a" href={locale.nav.batPillHref}>
            <Image src={batPill} height="28px" />
          </Box>
        </Box>
      </Container>
      <SwoopBottom swoop="fade" />
    </GradientBackground>
  )
}

export const MainSignIn = () => {
  return (
    <SignComponent
      heading={locale.main.signin.heading}
      subhead={locale.main.signin.subhead}
      inputPlaceholder={locale.main.signin.inputPlaceholder}
      btn={locale.main.signin.btn}
      tinyOne={locale.main.signin.tinyOne}
      tinyOneHref={locale.main.signin.tinyOneHref}
      tinyTwo={locale.main.signin.tinyTwo}
      tinyTwoHref={locale.main.signin.tinyTwoHref}
      footerOne={locale.main.footerOne}
      footerOneHref={locale.main.footerOneHref}
      footerTwo={locale.main.footerTwo}
      footerTwoHref={locale.main.footerTwoHref}
    />
  )
}

export const MainSignUp = () => {
  return (
    <SignComponent
      heading={locale.main.signup.heading}
      subhead={locale.main.signup.subhead}
      inputPlaceholder={locale.main.signup.inputPlaceholder}
      btn={locale.main.signup.btn}
      tinyOne={locale.main.signup.tinyOne}
      tinyOneHref={locale.main.signup.tinyOneHref}
      footerOne={locale.main.footerOne}
      footerOneHref={locale.main.footerOneHref}
      footerTwo={locale.main.footerTwo}
      footerTwoHref={locale.main.footerTwoHref}
    />
  )
}
