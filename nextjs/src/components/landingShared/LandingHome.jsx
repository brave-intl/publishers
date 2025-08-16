'use client';

import SwoopBottom from "~/images/swoop-bottom.svg";
import Icon from '@brave/leo/react/icon';
import BatPill from "~/images/built-with-bat-pill.jsx";
import styles from '@/styles/LandingPages.module.css';
import { useLocale, useTranslations } from 'next-intl';

export default function LandingHome() {
  const t = useTranslations();
  const locale = useLocale();

  return (
    <div className={`${styles['gradient-background']} ${styles['box']} flex-col`}>
      <div className={`${styles['box']} flex-col w-full max-w-1200`} role="main">
        <div className={`${styles['box']} ${styles['landing-home-container']}`}>
        {(locale !== 'ja') &&
            <a
              href={t("landingPages.nav.batPillHref")}
              rel="noopener"
              title={t("landingPages.nav.batPillHref")}
              aria-label={t("landingPages.nav.batPillAlt")}
            >
              <BatPill height="24px" alt={t("landingPages.nav.batPillAlt")} />
            </a>
          }
          <h1 className={`${styles['landing-headline']}`}>
            {t("landingPages.main.home.headline")}
          </h1>
          <p className={`${styles['landing-subhead']}`}>
            {t("landingPages.main.home.subhead")}
          </p>
          <div className={`${styles['box']} items-center flex-wrap flex-row py-[24px] w-full`}>
            <a rel="noopener" href="/sign-up">
              <button
                className={`${styles['primary-button']} mr-[24px]`}
                name={t("landingPages.main.home.btn.signup")}
              >
                {t("landingPages.main.home.btn.signup")}
              </button>
            </a>
            <a
              rel="noopener"
              href="/log-in"
              name={t('landingPages.main.home.btn.login')}
              className="text-white"
            >
              {t("landingPages.main.home.btn.login")}
            </a>
          </div>
          <h3 className={`${styles['get-started-text']} my-[1em]`}>
            {t("landingPages.main.home.examples.headline")}
          </h3>
          <div className={`${styles['box']} flex-row`}>
            <div className={`${styles['box']} ${styles['started-box']}`}>
              <div className={`${styles['box']} flex-row my-[8px]`}>
                <Icon className="text-white mr-[12px]" name="user" />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t("landingPages.main.home.examples.website")}
                </h3>
              </div>
              <div className={`${styles['box']} flex-row my-[8px]`}>
                <Icon className="text-white mr-[12px]" name="social-youtube" />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t("landingPages.main.home.examples.youtube")}
                </h3>
              </div>
            </div>
            <div className="sm:hidden md:flex w-[24px]"></div>
            <div className={`${styles['box']} ${styles['started-box']}`}>
              <div className={`${styles['box']} flex-row my-[8px]`}>
                <Icon className="text-white mr-[12px]" name="article" />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t("landingPages.main.home.examples.publication")}
                </h3>
              </div>
              <div className={`${styles['box']} flex-row my-[8px]`}>
                <Icon className="text-white mr-[12px]" name="social-twitch" />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t("landingPages.main.home.examples.Twitch")}
                </h3>
              </div>
            </div>
          </div>
        </div>
      </div>
      <SwoopBottom className="bottom-[-2px] absolute w-full z-0" />
    </div>
  );
};
