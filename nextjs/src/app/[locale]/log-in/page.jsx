'use client';

import { useEffect } from 'react';
import { useTranslations } from 'next-intl';
import Nav from "@/components/landingShared/Nav";
import SignComponent from "@/components/landingShared/SignComponent";
import styles from '@/styles/LandingPages.module.css';

export default function LogIn() {
  const t = useTranslations();
  useEffect(() => {
    document.title = "Log In - Brave Creators";
  }, [])
  
  return (
    <div className={`${styles['landing-wrapper']}`}>
      <Nav />
      <SignComponent
        heading={t("landingPages.main.signin.heading")}
        subhead={t("landingPages.main.signin.subhead")}
        inputPlaceholder={t("landingPages.main.signin.inputPlaceholder")}
        btn={t("landingPages.main.signin.btn")}
        tinyOne={t("landingPages.main.signin.tinyOne")}
        tinyOneHref="/sign-up"
        tinyTwo={t("landingPages.main.signin.tinyTwo")}
        tinyTwoHref="/publishers/auth/youtube_login"
        footerOne={t("landingPages.main.footerOne")}
        footerOneHref="https://basicattentiontoken.org/publisher-terms-of-service/"
        footerTwo={t("landingPages.main.footerTwo")}
        footerTwoHref="https://support.brave.com/hc/en-us"
        formId="signInForm"
        method="PUT"
      />
    </div>
  );
};
