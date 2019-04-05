import React, { useState, useEffect } from "react";
import { withRouter } from "react-router-dom";
import {
  Container,
  GradientBackground,
  PrimaryButton,
  SwoopBottom,
  StyledInput,
  Toast
} from "../../../components";

import batPill from "../../../components/img/built-with-bat-pill.svg";
import locale from "../../../locale/en";
import { Heading, Text, Box, Anchor, Form, Image } from "grommet";

import SentEmail from "../sentEmail";

// Sign up and sign in shared this component since
// they are so similar in structure
const SignComponent = props => {
  return (
    <React.Fragment>
      <Toast display={props.notification} />
      <Container
        animation={props.animation}
        role="main"
        justify="center"
        align="center"
        pad="large"
        id="zindex"
        fill
      >
        <Box width="540px" align="center">
          <Heading
            level="2"
            color="white"
            a11yTitle="Headline"
            textAlign="center"
            margin="small"
          >
            {props.heading}
          </Heading>
          <Text
            size="18px"
            color="rgba(255, 255, 255, .8)"
            textAlign="center"
            margin={{ bottom: "50px" }}
          >
            {props.subhead}
          </Text>
          <Box width="100%" margin={{ bottom: "30px" }}>
            <Form
              className="email-input"
              errors={props.errors}
              messages={{
                required: "Please enter a valid email address."
              }}
              onSubmit={props.submitForm}
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
            size="small"
          />
          <Anchor
            href={props.tinyTwoHref}
            label={props.tinyTwo}
            color="rgba(255, 255, 255, .8)"
            size="small"
          />
          <Box height="100px" />
        </Box>
        <Box className="terms-help" gap="large">
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
    </React.Fragment>
  );
};

const WrappedSignComponent = props => {
  const [notification, setNotification] = useState("hidden");
  const [animation, setAnimation] = useState("fadeIn");
  const [emailed, setEmailed] = useState(false);
  const [confetti, setConfetti] = useState(false);

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

    const result = await fetch(url, {
      // headers: {
      //   Accept: "application/json",
      //   "X-CSRF-Token": crsf,
      //   "X-Requested-With": "XMLHttpRequest",
      //   "Content-Type": "application/json"
      // },
      // method: props.method,
      // body: JSON.stringify(body)
    });

    if (result.ok) {
      // setNotification("bottom");
      setAnimation({
        type: "fadeOut",
        delay: 0,
        duration: 100,
        size: "xsmall"
      });
      setTimeout(function() {
        setEmailed(true);
      }, 150);
    }
  }

  return (
    <GradientBackground height="100vh" align="center">
      {emailed ? (
        <SentEmail confetti={confetti} />
      ) : (
        <SignComponent
          submitForm={submitForm}
          animation={animation}
          notification={notification}
          {...props}
        />
      )}
    </GradientBackground>
  );
};

export default withRouter(WrappedSignComponent);
