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

import { Loading } from "../../../components/icons/Loading";

import batPill from "../../../components/img/built-with-bat-pill.svg";
import locale from "../../../locale/en";
import { Heading, Text, Box, Anchor, Form, Image } from "grommet";

import SentEmail from "../sentEmail";

// Sign up and sign in shared this component since
// they are so similar in structure
const SignComponent = props => {
  const [notification, setNotification] = useState({ show: false });
  return (
    <React.Fragment>
      <Toast
        notification={notification}
        closeNotification={() => setNotification({ show: false })}
      />
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
              id={props.formId}
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
                icon={props.loading ? <Loading /> : <span />}
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
  const [notification, setNotification] = useState({ show: false });
  const [animation, setAnimation] = useState("fadeIn");
  const [emailed, setEmailed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [confetti, setConfetti] = useState(false);
  const [words, setWords] = useState({});

  const successSignInWords = {
    headline: locale.sign.signinSuccess,
    body: locale.sign.signinSuccessBody
  };

  const successSignUpWords = {
    headline: locale.sign.signupSuccess,
    body: locale.sign.signupSuccessBody
  };

  const submitForm = event => {
    doTheThing(event);
  };

  const tryAgain = event => {
    event.preventDefault();
    setNotification({ show: true, text: locale.sign.sentAgain });
  };

  async function doTheThing(body) {
    const url = "publishers/registrations.json";
    console.log(body.target.id);
    body.target.id === "signInForm"
      ? setWords(successSignInWords)
      : setWords(successSignUpWords);

    console.log(JSON.stringify(body.value));
    let crsf = document.head.querySelector("[name=csrf-token]");
    if (crsf) {
      crsf = crsf.getAttribute("content");
    }

    setLoading(true);
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

    setTimeout(function() {
      console.log("ye");
      setLoading(false);
    }, 250);

    if (result.ok) {
      setAnimation({
        type: "fadeOut",
        delay: 0,
        duration: 100,
        size: "xsmall"
      });
      setTimeout(function() {
        setEmailed(true);
        setConfetti(true);
      }, 250);
    } else {
      setNotification({ show: true, text: "Something went wrong!" });
    }
  }

  return (
    <GradientBackground height="100vh" align="center">
      {emailed ? (
        <SentEmail
          confetti={confetti}
          notification={notification}
          closeNotification={() => setNotification({ show: false })}
          tryAgain={tryAgain}
          words={words}
        />
      ) : (
        <SignComponent
          submitForm={submitForm}
          animation={animation}
          loading={loading}
          notification={notification}
          {...props}
        />
      )}
    </GradientBackground>
  );
};

export default withRouter(WrappedSignComponent);
