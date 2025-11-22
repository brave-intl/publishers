'use client';

import { useEffect } from 'react';
import { useTranslations } from 'next-intl';
import Nav from "@/components/landingShared/Nav";
import SignComponent from "@/components/landingShared/SignComponent";
import TermsOfService from "@/components/landingShared/TermsOfService";
import styles from '@/styles/LandingPages.module.css';

export default function SignUp() {
  const t = useTranslations();
  useEffect(() => {
    document.title = "Become a Creator - Brave Creators";
  }, [])

  return (
    <div className={`${styles['landing-wrapper']}`}>
      <Nav />
      <SignComponent
        heading={t("landingPages.main.signup.heading")}
        subhead={t("landingPages.main.signup.subhead")}
        inputPlaceholder={t("landingPages.main.signup.inputPlaceholder")}
        btn={t("landingPages.main.signup.btn")}
        tinyOne={t("landingPages.main.signup.tinyOne")}
        tinyOneHref="/log-in"
        footerOne={t("landingPages.main.footerOne")}
        footerTwo={t("landingPages.main.footerTwo")}
        formId="signUpForm"
        termsOfService={<TermsOfService />}
        method="POST"
      />
    </div>
  );
};
