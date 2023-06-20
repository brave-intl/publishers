import React, { useState } from "react";
import { withRouter } from "../../../withRouter";
import {
  Container,
  GradientBackground,
  PrimaryButton,
  SwoopBottom,
  StyledInput,
  Toast
} from "../../../components";

import { Loading } from "../../../components/icons/Loading";

import { FormattedMessage } from 'react-intl';
import { useIntl } from 'react-intl';
import { Heading, Text, Box, Anchor, Form } from "grommet";

import SentEmail from "../sentEmail";

// Sign up and sign in shared this component since
// they are so similar in structure
const SignComponent = props => {
  const intl = useIntl();
  return (
    <React.Fragment>
      <Toast
        notification={props.notification}
        closeNotification={() => props.setNotification({ show: false })}
      />
      <Container
        animation={props.animation}
        role="main"
        align="center"
        pad="large"
        id="zindex"
        fill
        margin={{ top: "80px" }}
      >
        <Box width="540px" flex={{ shrink: 0 }} align="center">
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
              id={props.formId}
              onSubmit={props.submitForm}
            >
              <StyledInput
                name="email"
                type="email"
                autoFocus
                placeholder={intl.formatMessage({
                  id: "main.signin.inputPlaceholder"
                })}
                validate={(fieldData, _) => {
                  if (!fieldData) {
                    return intl.formatMessage({ id: "main.validEmail" });
                  }
                }}
              />

              {props.termsOfService}

              <PrimaryButton
                label={props.btn}
                icon={props.loading ? <Loading /> : null}
                type="submit"
                alignSelf="center"
              />
            </Form>

            <Box align="center" pad="xlarge">
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
            </Box>
          </Box>
        </Box>

        <Box gap="large">
          <Box direction="row" gap="small" align="center">
            <Anchor
              label={props.footerOne}
              href={props.footerOneHref}
              color="rgba(255, 255, 255, .8)"
              size="small"
            />
            <Text color="rgba(255, 255, 255, .8)">|</Text>
            <Anchor
              label={props.footerTwo}
              href={props.footerTwoHref}
              color="rgba(255, 255, 255, .8)"
              size="small"
            />
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
  const intl = useIntl();

  const successSignInWords = {
    headline: intl.formatMessage({ id: 'sign.signinSuccess' }),
    body: intl.formatMessage({ id: 'sign.signinSuccessBody' })
  };

  const successSignUpWords = {
    headline: intl.formatMessage({ id: 'sign.signupSuccess' }),
    body: intl.formatMessage({ id: 'sign.signupSuccessBody' })
  };

  const submitForm = event => {
    // Prevent people from endlessly submitting
    event.target.blur();
    if (loading) {
      return;
    }

    // Analytics
    if (window._paq) {
      let action = "StartFlowClicked";
      let value = "Landing";

      if (event.target.id === "signInForm") {
        action = "NewAuthLoginClicked";
        value = "NewAuthFlow";
      }

      window._paq.push(["trackEvent", action, "Clicked", value]);
    }

    setLoading(true);
    setNotification({ show: false, text: "" });
    sendToServer(event);
  };

  const tryAgain = event => {
    event.preventDefault();
    setNotification({ show: true, text: <FormattedMessage id="sign.sentAgain" /> });
  };

  async function sendToServer(body) {
    const url = "publishers/registrations.json";
    body.target.id === "signInForm"
      ? setWords(successSignInWords)
      : setWords(successSignUpWords);

    let crsf = document.head.querySelector("[name=csrf-token]");
    if (crsf) {
      crsf = crsf.getAttribute("content");
    }

    await fetch(url, {
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": crsf,
        "X-Requested-With": "XMLHttpRequest",
        "Content-Type": "application/json"
      },
      method: props.method,
      body: JSON.stringify(body.value)
    }).then(response => {
      setLoading(false);

      if (response.ok) {
        submitSuccess();
      } else {
        response
          .json()
          .then(json => {
            setNotification({ show: true, text: json.message });
          })
          .catch(errorText => {
            setNotification({ show: true, text: "Something went wrong." });
          });
      }
    });
  }

  const submitSuccess = () => {
    setAnimation({
      type: "fadeOut",
      delay: 0,
      duration: 100,
      size: "xsmall"
    });
    setTimeout(function () {
      setEmailed(true);
      setConfetti(true);
    }, 250);
  };

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
          setNotification={setNotification}
          {...props}
        />
      )}
    </GradientBackground>
  );
};

export default withRouter(WrappedSignComponent);
