'use client';

import { useState } from "react";
import SwoopBottom from "~/images/swoop-bottom.svg";
import styles from '@/styles/LandingPages.module.css';
import { useTranslations } from 'next-intl';
import { apiRequest } from "@/lib/api";
import ProgressRing from '@brave/leo/react/progressRing';
import SentEmail from "./SentEmail";
import LandingToast from "./LandingToast";

export default function SignComponent({
  heading,
  subhead,
  inputPlaceholder,
  btn,
  tinyOne,
  tinyOneHref,
  tinyTwo,
  tinyTwoHref,
  footerOne,
  footerOneHref,
  footerTwo,
  footerTwoHref,
  formId,
  termsOfService,
  method
}) {
  const [notification, setNotification] = useState({ show: false });
  const [animation, setAnimation] = useState("fadeIn");
  const [emailed, setEmailed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [confetti, setConfetti] = useState(false);
  const [words, setWords] = useState({});
  const [email, setEmail] = useState("");
  const [emailError, setEmailError] = useState("");
  const t = useTranslations();

  const successSignInWords = {
    headline: t("landingPages.sign.signinSuccess"),
    body: t("landingPages.sign.signinSuccessBody")
  };

  const successSignUpWords = {
    headline: t("landingPages.sign.signupSuccess"),
    body: t("landingPages.sign.signupSuccessBody")
  };

  function validateEmail() {
    if (!email) {
      setEmailError(t("landingPages.main.validEmail"));
      return false;
    }
    setEmailError("");
    return true;
  };

  function handleEmailChange(e) {
    setEmail(e.target.value);
    if (emailError) {
      setEmailError("");
    }
  };

  function submitForm(event) {
    event.preventDefault();
    // Prevent people from endlessly submitting
    event.target.blur();
    if (loading) {
      return;
    }

    if (!validateEmail()) {
      return;
    }

    setLoading(true);
    setNotification({ show: false, text: "" });
    sendToServer(event);
  };

  function tryAgain(event) {
    event.preventDefault();
    setNotification({ show: true, text: t("landingPages.sign.sentAgain")});
  };

  async function sendToServer(body) {
    const url = "registrations";
    formId === "signInForm"
      ? setWords(successSignInWords)
      : setWords(successSignUpWords);

    const res = await apiRequest(url, method, {email: body.target[0].value, terms_of_service: body.target[1].value});
    setLoading(false);
    if (res.errors) {
      setNotification({ show: true, text: errors });
    } else {
      submitSuccess();
    }
  }

  function submitSuccess() {
    setEmailed(true);
    // setAnimation({
    //   type: "fadeOut",
    //   delay: 0,
    //   duration: 100,
    //   size: "xsmall"
    // });
  };

  return (
    <div className={`${styles['gradient-background']} ${styles['box']} flex-col h-lvh`}>
      <div role='main' className={`${styles['box']} ${styles['sign-container']}`}>
        {emailed ? (
          <SentEmail
            confetti={confetti}
            tryAgain={tryAgain}
            words={words}
          />
        ) : (
          <div className="mt-[80px]">
            <div className={`${styles['box']} flex-col flex-center w-[540px]`}>
              <h2 className={`${styles['sign-title']} m-[12px]`}>{heading}</h2>
              <div className="text-center mb-[50px] text-white/80 text-[18px]">
                {subhead}
              </div>
              <div className={`${styles['box']} mb-[30px] flex-col w-full`}>
                <form
                  className="flex flex-col w-full"
                  id={formId}
                  onSubmit={submitForm}
                >

                  <div className="mb-[24px]">
                    <input
                      name="email"
                      type="email"
                      autoFocus
                      className={`${styles['login-input']} ${emailError && "border-red-500"}`}
                      autoComplete="off"
                      onChange={handleEmailChange}
                      placeholder={t("landingPages.main.signin.inputPlaceholder")}
                      value={email}
                    />

                    {emailError && (
                      <p className={`${styles['login-errors']}`}>{emailError}</p>
                    )}
                  </div>

                  {termsOfService}

                  <button
                    className={`self-center ${styles['primary-button']}`}
                    type="submit"
                  >
                    {loading ? (
                      <div className="max-h-[24px]">
                        <ProgressRing className={`${styles['progress-btn']}`}/> 
                      </div>
                    ) : btn }
                  </button>
                </form>

                <div className={`${styles['box']} flex-col flex-center p-[96px]`}>
                  <a
                    href={tinyOneHref}
                    className={`${styles['link-text']} inline-flex`}
                    rel="noopener"
                  >
                    {tinyOne}
                  </a>
                </div>
              </div>
            </div>

            <div className={`${styles['box']} flex flex-col`}>
              <div className={`${styles['box']} flex flex-center flex-row`}>
                <a
                  className={`${styles['link-text']} inline-flex`}
                  href={footerOneHref}
                  rel="noopener"
                >
                  {footerOne}
                </a>
                <span className={`${styles['link-text']}`}>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;</span>
                <a
                  className={`${styles['link-text']} inline-flex`}
                  href={footerTwoHref}
                  rel="noopener"
                >
                  {footerTwo}
                </a>
              </div>
            </div>
          </div>
        )}
      </div>
      <LandingToast
        notification={notification}
        closeNotification={() => setNotification({ show: false })}
      />
      <SwoopBottom className={`${styles['fade']}`} />
    </div>
  );
};
