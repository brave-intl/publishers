import React from "react";
import Confetti from "react-dom-confetti";
import {
  BatLockup,
  ConfettiConfig,
  Container,
  IconContainer,
  SignCommunityIcon,
  SignInfoIcon,
  SignMessageIcon,
  SignRedditIcon,
  SwoopBottom,
  Toast
} from "../../../components";

import batPill from "../../../components/img/built-with-bat-pill.svg";
import locale from "../../../locale/en";
import { FormattedMessage } from 'react-intl';
import { Heading, Text, Box, Anchor, Image } from "grommet";

// Sign up and sign in shared this component since
// they are so similar in structure. It only fires
// in instances of successful sign up or sign in email being sent
const SentEmail = props => {
  return (
    <React.Fragment>
      <Container
        animation="fadeIn"
        role="main"
        justify="center"
        align="center"
        pad="large"
        id="zindex"
        fill
      >
        <Toast
          notification={props.notification}
          closeNotification={props.closeNotification}
        />
        <Box
          margin={{ bottom: "30px" }}
          animation={{
            type: "fadeIn",
            delay: 300,
            duration: 2000
          }}
        >
          <IconContainer height="160px">
            <BatLockup />
          </IconContainer>
        </Box>
        <Box width="600px" align="center">
          <Heading
            level="2"
            color="white"
            a11yTitle="Headline"
            textAlign="center"
            margin="medium"
          >
            {props.words.headline}
          </Heading>
          <Text
            as="p"
            size="18px"
            color="rgba(255, 255, 255, .8)"
            textAlign="center"
            margin={{ top: "0", bottom: "40px" }}
          >
            {props.words.body}
            <Anchor color="rgba(255, 255, 255, .8)" onClick={props.tryAgain}>
              <strong>{<FormattedMessage id="sign.signTryAgain"/>}</strong>
            </Anchor>
          </Text>
          <Box
            direction="row"
            animation={{
              type: "fadeIn",
              delay: 1000,
              duration: 2000
            }}
          >
            <a
              href={locale.sign.iconHelpHref}
              className="sign-icon"
              title={<FormattedMessage id="sign.iconHelpTitle"/>}
            >
              <SignInfoIcon />
            </a>
            <a
              href={locale.sign.iconMessageHref}
              className="sign-icon"
              title={<FormattedMessage id="sign.iconMessageTitle"/>}
            >
              <SignMessageIcon />
            </a>
            <a
              href={locale.sign.iconRedditHref}
              className="sign-icon"
              title={<FormattedMessage id="sign.iconRedditTitle"/>}
            >
              <SignRedditIcon />
            </a>
            <a
              href={locale.sign.iconCommunityHref}
              className="sign-icon"
              title={<FormattedMessage id="sign.iconCommunityTitle"/>}
            >
              <SignCommunityIcon />
            </a>
          </Box>
          <div className="spacer" />
          <Box
            id="terms-help"
            gap="large"
            animation={{
              type: "fadeIn",
              delay: 1000,
              duration: 2000
            }}
          >
            <Box
              as="a"
              href={locale.nav.batPillHref}
              aria-label={<FormattedMessage id="nav.batPillAlt"/>}
            >
              <Image src={batPill} height="28px" />
            </Box>
          </Box>
        </Box>
      </Container>
      <SwoopBottom swoop="fade" />
      <Confetti active={props.confetti} config={ConfettiConfig} />
    </React.Fragment>
  );
};

export default SentEmail;
