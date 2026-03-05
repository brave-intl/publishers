'use client';

import { useLocale, useTranslations } from 'next-intl';
import Link from '@brave/leo/react/link';
import Logo from '~/images/brave_color_darkbackground.png';
import BatPill from '@/assets/built-with-bat-pill.jsx';
import styles from '@/styles/LandingPages.module.css';
import MobileNav from './MobileNav';

function DefaultNav() {
  const t = useTranslations();
  const locale = useLocale();

  return (
    <div className={`${styles['nav-wrapper']}`} id='nav'>
      <div className={`${styles['nav-container']}`}>
        <div className={`${styles['box']} flex-row`}>
          <Link href='/' title='Home'>
            <div className='max-w-[125px]'>
              <img src={Logo.src} alt={t('landingPages.nav.logoAlt')} />
            </div>
          </Link>
          <div className='w-[40px] flex-initial self-stretch'></div>
          {locale !== 'ja' && (
            <Link
              href='http://www.basicattentiontoken.org'
              title={t('landingPages.nav.batPillHref')}
              aria-label={t('landingPages.nav.batPillAlt')}
            >
              <BatPill height='24px' alt={t('landingPages.nav.batPillAlt')} />
            </Link>
          )}
        </div>
        <div className={`${styles['box']} flex-row`}>
          <a
            href='/sign-up'
            aria-label='Sign up to be a Brave Creator'
            className={`${styles['landing-nav-link']}`}
          >
            {t('landingPages.nav.signup')}
          </a>
          <div className='w-[48px] flex-initial self-stretch'></div>
          <a
            href='/log-in'
            aria-label='Log in to your Brave Creator dashboard'
            className={`${styles['landing-nav-link']} ${styles['button-link']}`}
          >
            {t('landingPages.nav.login')}
          </a>
        </div>
      </div>
    </div>
  );
}

export default function Nav() {
  return (
    <>
      <div className='block md:hidden'>
        <MobileNav />
      </div>
      <div className='hidden md:block'>
        <DefaultNav />
      </div>
    </>
  );
}
