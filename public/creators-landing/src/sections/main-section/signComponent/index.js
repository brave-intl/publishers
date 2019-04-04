import React, { useState, useEffect } from "react";
import { withRouter } from "react-router-dom";
import {
  Container,
  GradientBackground,
  PrimaryButton,
  SwoopBottom,
  StyledInput,
  CloseIcon,
  NotificationWrapper,
  InfoIcon,
  IconContainer
} from "../../../components";

import batPill from "../../../components/img/built-with-bat-pill.svg";
import locale from "../../../locale/en";
import { Heading, Text, Box, Anchor, Layer, Form, Image, Button } from "grommet";

function NotificationLayer(props) {
  return (
    <Layer
      position={props.display}
      modal={false}
      margin={{vertical: "xlarge", horizontal: "none"}}
      responsive={false}
      className="notification-layer"
      plain
    >
      <NotificationWrapper
        align="center"
        direction="row"
        gap="small"
        justify="between"
        round="medium"
        elevation="medium"
        pad={{ vertical: "small", horizontal: "medium" }}
        background="#F3F3FD"
      >
        <Box align="center" direction="row" gap="small">
          <IconContainer minWidth="32px" height="32px" width="32px" color="#339AF0">
            <InfoIcon />
          </IconContainer>
          <Text>An access link has been sent and this needs to be longer cause I'm testing.</Text>
          <Button icon={<CloseIcon />} onClick={() => {}} plain />
        </Box>
      </NotificationWrapper>
    </Layer>
  );
}

// Sign up and sign in shared this component since
// they are so similar in structure
const SignComponent = props => {
  const [notification, setNotification] = useState("hidden");
  const [thing, setThing] = useState("fadeIn");

  useEffect(() => {
    if (notification === "hidden") {
      return;
    }
    const timer = window.setInterval(() => {
      // setNotification("hidden");
    }, 5000);
    return () => {
      // Return callback to run on unmount.
      window.clearInterval(timer);
    };
  });

  const submitForm = event => {
    doTheThing(event.value);
  };

  async function doTheThing(body) {
    const url = "publishers/registrations.json";

    console.log(JSON.stringify(body));
    let crsf = document.head.querySelector("[name=csrf-token]");
    if (crsf) {
      crsf = crsf.getAttribute("content");
    }

    // const result = await fetch(url, {
    //   headers: {
    //     Accept: "application/json",
    //     "X-CSRF-Token": crsf,
    //     "X-Requested-With": "XMLHttpRequest",
    //     "Content-Type": "application/json"
    //   },
    //   method: "POST",
    //   body: JSON.stringify(body)
    // });

    // if (result.ok) {
    // setNotification("bottom");
    setThing("fadeOut");
    const timer = window.setInterval(() => {
      props.history.push("sent-email");
    }, 150);
    return () => {
      window.clearInterval(timer);
    };
  }

  return (
    <GradientBackground height="100vh" align="center">
      <NotificationLayer display={notification} />
      <Container
        animation={thing}
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
              onSubmit={submitForm}
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
  );
};

export default withRouter(SignComponent);
