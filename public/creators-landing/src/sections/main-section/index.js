import React from "react";
import {
  Container,
  GradientBackground,
  H2,
  PrimaryButton,
  UserIcon,
  YouTubeIcon,
  PublicationIcon,
  TwitchIcon,
  SwoopBottom
} from "../../components";

import { Link } from "react-router-dom";
import SignComponent from "./signComponent";
import batPill from "../../components/img/built-with-bat-pill.svg";
import { Heading, Box, Image } from "grommet";
import locale from "../../locale/en";

const logAction = (action, value) => {
  if (window._paq) {
    window._paq.push(["trackEvent", action, "Clicked", value]);
  }
};

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
            <Link
              to={locale.main.home.btn.signupHref}
              onClick={() => logAction("StartSignupClicked", "Landing")}
            >
              <PrimaryButton label={locale.main.home.btn.signup} />
            </Link>
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
  );
};

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
      formId="signInForm"
      method="PUT"
    />
  );
};

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
      formId="signUpForm"
      method="POST"
    />
  );
};
