'use client';

import React from "react";
import { useLocale, useTranslations } from 'next-intl';
import Link from '@brave/leo/react/link';
import ButtonMenu from '@brave/leo/react/buttonMenu';
import Icon from '@brave/leo/react/icon';
import Logo from "~/images/brave_color_darkbackground.png";
import styles from '@/styles/LandingPages.module.css';

export default function MobileNav() {
  const t = useTranslations();

  return (
    <div className={`${styles['nav-wrapper']}`} id="nav">
      <div className={`${styles['nav-container']}`}>
        <Link href="/">
          <img src={Logo.src} className='max-w-[125px]' alt={t("landingPages.nav.logoAlt")} />
        </Link>
        <ButtonMenu aria-label="Nav">
          <span slot="anchor-content"><Icon className='text-white' name='hamburger-menu' /></span>
          <leo-menu-item>
            <Link href="/sign-up">
              {t("landingPages.nav.signup")}
            </Link>
          </leo-menu-item>
          <leo-menu-item>
            <Link href="/log-in">
              {t("landingPages.nav.login")}
            </Link>
          </leo-menu-item>
        </ButtonMenu>
      </div>
    </div>
  );
};
