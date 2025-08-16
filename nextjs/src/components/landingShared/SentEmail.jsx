'use client';

import { useState, useEffect } from "react";
import Confetti from "react-dom-confetti";
import Button from '@brave/leo/react/button';
import Link from '@brave/leo/react/link';
import Icon from '@brave/leo/react/icon';
import LandingToast from "./LandingToast";
import SwoopBottom from "~/images/swoop-bottom.svg";
import BatLockup from "./BatLockup.jsx";
import { useTranslations } from 'next-intl';
import BatPill from "~/images/built-with-bat-pill.jsx";
import styles from '@/styles/LandingPages.module.css';

const ConfettiConfig = {
  angle: "90",
  spread: "61",
  startVelocity: "68",
  elementCount: "70",
  dragFriction: "0.11",
  duration: "2500",
  delay: "2",
  width: "16px",
  height: "10px",
  colors: ["#a864fd", "#29cdff", "#78ff44", "#ff718d", "#fdff6a"]
};

// Sign up and sign in shared this component since
// they are so similar in structure. It only fires
// in instances of successful sign up or sign in email being sent
export default function SentEmail({ tryAgain, words }) {
  const [activeConfetti, setActiveConfetti] = useState(false)
  const t = useTranslations();

  useEffect(() => {
    // confetti is triggered by the change in state from false to true,
    // so you can't just set it to true initially
    setActiveConfetti(true)
  }, [])
  
  return (
    <>
      <div className={`${styles['box']} ${styles['bat-animation']} flex-col mb-30px`}>
        <svg height="160px">
          <BatLockup />
        </svg>
      </div>
      <div className={`${styles['box']} flex-col flex-center w-[600px]`}>
        <h2 className={`${styles['sign-title']} m-[24px]`}>
          {words.headline}
        </h2>
        <p className={`${styles['email-sent-text']}`}>
          {words.body}
          <a rel='noopener' className="text-white opacity-80 cursor-pointer" onClick={tryAgain}>
            <strong>{t("landingPages.sign.signTryAgain")}</strong>
          </a>
        </p>
        <div className={`${styles['box']} flex-row ${styles['sent-email-icon-container']}`}>
          <a
            rel="noopener"
            href={t('landingPages.sign.iconHelpHref')}
            className={`${styles['sent-email-sign-icon']}`}
            title={t('landingPages.sign.iconHelpTitle')}
          >
            <Icon name='info-outline' />
          </a>
          <a
            rel="noopener"
            href={t('landingPages.sign.iconMessageHref')}
            className={`${styles['sent-email-sign-icon']}`}
            title={t('landingPages.sign.iconMessageTitle')}
          >
            <Icon name='email' />
          </a>
          <a
            rel="noopener"
            href={t('landingPages.sign.iconRedditHref')}
            className={`${styles['sent-email-sign-icon']}`}
            title={t('landingPages.sign.iconRedditTitle')}
          >
            <Icon name='social-reddit-nobackground' />
          </a>
          <a
            rel="noopener"
            href={t('landingPages.sign.iconCommunityHref')}
            className={`${styles['sent-email-sign-icon']}`}
            title={t('landingPages.sign.iconCommunityTitle')}
          >
            <Icon name='product-bat-outline' />
          </a>
        </div>
        <div className="flex h-[60px]" />
        <div
          className={`${styles['box']} flex-column ${styles['sent-email-icon-container']}`}
          id="terms-help"
        >
          <Link
            href={t('landingPages.nav.batPillHref')}
            aria-label={t("landingPages.nav.batPillAlt")}
          >
            <BatPill height="28px" />
          </Link>
        </div>
      </div>
      <Confetti className="absolute bottom-0" active={activeConfetti} config={ConfettiConfig} />
    </>
  );
};
