'use client';

import SwoopBottom from '@/assets/swoop-bottom';
import Icon from '@brave/leo/react/icon';
import BatPill from '@/assets/built-with-bat-pill';
import styles from '@/styles/LandingPages.module.css';
import { useLocale, useTranslations } from 'next-intl';

export default function LandingHome() {
  const t = useTranslations();
  const locale = useLocale();

  return (
    <div
      className={`${styles['gradient-background']} ${styles['box']} flex-col`}
    >
      <div
        className={`${styles['box']} w-full max-w-[1200px] flex-col`}
        role='main'
      >
        <div className={`${styles['box']} ${styles['landing-home-container']}`}>
          {locale !== 'ja' && (
            <a
              href={t('landingPages.nav.batPillHref')}
              rel='noopener'
              title={t('landingPages.nav.batPillHref')}
              aria-label={t('landingPages.nav.batPillAlt')}
            >
              <BatPill height='24px' alt={t('landingPages.nav.batPillAlt')} />
            </a>
          )}
          <h1 className={`${styles['landing-headline']}`}>
            {t('landingPages.main.home.headline')}
          </h1>
          <p className={`${styles['landing-subhead']}`}>
            {t('landingPages.main.home.subhead')}
          </p>
          <div
            className={`${styles['box']} w-full flex-row flex-wrap items-center py-[24px]`}
          >
            <a rel='noopener' href='/sign-up'>
              <button
                className={`${styles['primary-button']} mr-[24px]`}
                name={t('landingPages.main.home.btn.signup')}
              >
                {t('landingPages.main.home.btn.signup')}
              </button>
            </a>
            <a
              rel='noopener'
              href='/log-in'
              name={t('landingPages.main.home.btn.login')}
              className='text-white'
            >
              {t('landingPages.main.home.btn.login')}
            </a>
          </div>
          <h3 className={`${styles['get-started-text']} my-[1em]`}>
            {t('landingPages.main.home.examples.headline')}
          </h3>
          <div className={`${styles['box']} flex-row`}>
            <div className={`${styles['box']} ${styles['started-box']}`}>
              <div className={`${styles['box']} my-[8px] flex-row`}>
                <Icon className='mr-[12px] text-white' name='user' />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t('landingPages.main.home.examples.website')}
                </h3>
              </div>
              <div className={`${styles['box']} my-[8px] flex-row`}>
                <Icon className='mr-[12px] text-white' name='social-youtube' />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t('landingPages.main.home.examples.youtube')}
                </h3>
              </div>
            </div>
            <div className='w-[24px] sm:hidden md:flex'></div>
            <div className={`${styles['box']} ${styles['started-box']}`}>
              <div className={`${styles['box']} my-[8px] flex-row`}>
                <Icon className='mr-[12px] text-white' name='article' />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t('landingPages.main.home.examples.publication')}
                </h3>
              </div>
              <div className={`${styles['box']} my-[8px] flex-row`}>
                <Icon className='mr-[12px] text-white' name='social-twitch' />
                <h3 className={`${styles['get-started-text']} m-0`}>
                  {t('landingPages.main.home.examples.Twitch')}
                </h3>
              </div>
            </div>
          </div>
        </div>
      </div>
      <SwoopBottom className='absolute bottom-[-2px] z-0 w-full' />
    </div>
  );
}
