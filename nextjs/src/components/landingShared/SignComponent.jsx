'use client';

import { useState, useEffect } from 'react';
import SwoopBottom from '~/images/swoop-bottom.svg';
import styles from '@/styles/LandingPages.module.css';
import { useTranslations } from 'next-intl';
import { apiRequest } from '@/lib/api';
import ProgressRing from '@brave/leo/react/progressRing';
import SentEmail from './SentEmail';
import LandingToast from './LandingToast';

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
  footerTwo,
  formId,
  termsOfService,
  method,
}) {
  const [notification, setNotification] = useState({ show: false });
  const [animation, setAnimation] = useState('fadeIn');
  const [emailed, setEmailed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [confetti, setConfetti] = useState(false);
  const [words, setWords] = useState({});
  const [email, setEmail] = useState('');
  const [tosLink, setTosLink] = useState('');
  const [helpLink, setHelpLink] = useState('');
  const [emailError, setEmailError] = useState('');
  const t = useTranslations();

  const successSignInWords = {
    headline: t('landingPages.sign.signinSuccess'),
    body: t('landingPages.sign.signinSuccessBody'),
  };

  const successSignUpWords = {
    headline: t('landingPages.sign.signupSuccess'),
    body: t('landingPages.sign.signupSuccessBody'),
  };

  useEffect(() => {
    getTosLinks();
  }, []);

  async function getTosLinks() {
    const res = await apiRequest('registrations/tos_links', 'GET');
    setTosLink(res['tos']);
    setHelpLink(res['help']);
  }

  function validateEmail() {
    if (!email) {
      setEmailError(t('landingPages.main.validEmail'));
      return false;
    }
    setEmailError('');
    return true;
  }

  function handleEmailChange(e) {
    setEmail(e.target.value);
    if (emailError) {
      setEmailError('');
    }
  }

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
    setNotification({ show: false, text: '' });
    sendToServer(event);
  }

  async function tryAgain(event) {
    event.preventDefault();

    const res = await apiRequest(url, method, { email: email });

    if (res.errors) {
      setNotification({ show: true, text: errors });
    } else {
      setNotification({ show: true, text: t('landingPages.sign.sentAgain') });
    }
  }

  async function sendToServer(body) {
    const url = 'registrations';
    formId === 'signInForm'
      ? setWords(successSignInWords)
      : setWords(successSignUpWords);

    const res = await apiRequest(url, method, {
      email: body.target[0].value,
      terms_of_service: body.target[1].value,
    });
    setLoading(false);
    if (res.errors) {
      setNotification({ show: true, text: errors });
    } else {
      submitSuccess();
    }
  }

  function submitSuccess() {
    setEmailed(true);
  }

  return (
    <div
      className={`${styles['gradient-background']} ${styles['box']} h-lvh flex-col`}
    >
      <div
        role='main'
        className={`${styles['box']} ${styles['sign-container']}`}
      >
        {emailed ? (
          <SentEmail confetti={confetti} tryAgain={tryAgain} words={words} />
        ) : (
          <div className='mt-[80px]'>
            <div className={`${styles['box']} flex-center w-[540px] flex-col`}>
              <h2 className={`${styles['sign-title']} m-[12px]`}>{heading}</h2>
              <div className='mb-[50px] text-center text-[18px] text-white/80'>
                {subhead}
              </div>
              <div className={`${styles['box']} mb-[30px] w-full flex-col`}>
                <form
                  className='flex w-full flex-col'
                  id={formId}
                  onSubmit={submitForm}
                >
                  <div className='mb-[24px]'>
                    <input
                      name='email'
                      type='email'
                      autoFocus
                      className={`${styles['login-input']} ${emailError && 'border-red-500'}`}
                      autoComplete='off'
                      onChange={handleEmailChange}
                      placeholder={t(
                        'landingPages.main.signin.inputPlaceholder',
                      )}
                      value={email}
                    />

                    {emailError && (
                      <p className={`${styles['login-errors']}`}>
                        {emailError}
                      </p>
                    )}
                  </div>

                  {termsOfService}

                  <button
                    className={`self-center ${styles['primary-button']}`}
                    type='submit'
                  >
                    {loading ? (
                      <div className='max-h-[24px]'>
                        <ProgressRing className={`${styles['progress-btn']}`} />
                      </div>
                    ) : (
                      btn
                    )}
                  </button>
                </form>

                <div
                  className={`${styles['box']} flex-center flex-col p-[96px]`}
                >
                  <a
                    href={tinyOneHref}
                    className={`${styles['link-text']} inline-flex`}
                    rel='noopener'
                  >
                    {tinyOne}
                  </a>
                </div>
              </div>
            </div>

            <div className={`${styles['box']} flex flex-col`}>
              <div className={`${styles['box']} flex-center flex flex-row`}>
                <a
                  className={`${styles['link-text']} inline-flex`}
                  href={tosLink}
                  rel='noopener'
                >
                  {footerOne}
                </a>
                <span className={`${styles['link-text']}`}>
                  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
                </span>
                <a
                  className={`${styles['link-text']} inline-flex`}
                  href={helpLink}
                  rel='noopener'
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
}
