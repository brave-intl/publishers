'use client';

import Button from '@brave/leo/react/button';
import ControlItem from '@brave/leo/react/controlItem';
import Hr from '@brave/leo/react/hr';
import Icon from '@brave/leo/react/icon';
import Link from '@brave/leo/react/link';
import Navigation from '@brave/leo/react/navigation';
import NavigationActions from '@brave/leo/react/navigationActions';
import NavigationHeader from '@brave/leo/react/navigationHeader';
import NavigationItem from '@brave/leo/react/navigationItem';
import NavigationMenu from '@brave/leo/react/navigationMenu';
import SegmentedControl from '@brave/leo/react/segmentedControl';
import Image from 'next/image';
import NavigationOptions from './NavigationOptions';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import styles from '@/styles/Layout.module.css';

import UserProvider from '@/components/UserProvider';

import Logo from '~/images/brave_creators_logo.png';

export default function NavigationLayout({ children }) {
  const t = useTranslations();
  const [theme, setTheme] = useState('auto');
  const [route, setRoute] = useState('');
  const [dismissCrypto, setDismissCrypto] = useState(false);

  useEffect(() => {
    setTheme(localStorage.getItem('theme') || 'auto');
    setRoute(window.location.pathname);
  }, []);

  function updateTheme(theme) {
    setTheme(theme);
    document.body.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
  }

  return (
    <UserProvider>
      <div className='flex-column flex'>
        <Navigation
          className={`inline-block max-w-[280px] min-w-[280px] ${styles['nav-background']}`}
        >
          <NavigationHeader>
            <Image
              src={Logo}
              alt='Brave Creators Logo'
              priority={true}
              width={110}
            />
          </NavigationHeader>
          <NavigationOptions />
          <div
            className={`${dismissCrypto ? 'hidden' : ''} ${
              styles['crypto-contributions']
            }`}
          >
            <h4 className='mb-1 w-3/5 mobile leading-relaxed'>
              {t('NavDropdown.crypto_contributions_header')}
            </h4>
            <p className='small-regular leading-relaxed'>
              {t('NavDropdown.crypto_contributions_text')}{' '}
              <Link href=''>{t('shared.learn_more')}</Link>
              {' - '}
              <Button
                kind='plain'
                className='underline font-normal'
                onClick={() => {
                  setDismissCrypto(true);
                }}
              >
                {t('shared.dismiss')}
              </Button>
            </p>
          </div>
          <NavigationActions slot='actions'>
            <div className={styles['theme-switcher']}>
              <span className={styles.theme}>Theme</span>
              <SegmentedControl size='tiny' value={theme} onChange={(e)=>{updateTheme(e.detail.value)}}>
                <ControlItem value='light'>
                  <Icon name='theme-light' />
                </ControlItem>
                <ControlItem value='dark'>
                  <Icon name='theme-dark' />
                </ControlItem>
                <ControlItem value='system'>
                  <Icon name='theme-system' />
                </ControlItem>
              </SegmentedControl>
            </div>
            <Hr />
            <div className='action-items'>
              <NavigationItem
                outsideList={true}
                icon='help-outline'
                href='/faqs'
              >
                {t('NavDropdown.faqs')}
              </NavigationItem>
              <NavigationItem
                outsideList={true}
                icon='message-bubble-ask'
                href='https://support.brave.com/hc/en-us/'
              >
                {t('NavDropdown.support')}
              </NavigationItem>
              <NavigationItem
                outsideList={true}
                icon='outside'
                href='/publishers/log_out'
              >
                {t('NavDropdown.log_out')}
              </NavigationItem>
            </div>
          </NavigationActions>
        </Navigation>
        {children}
      </div>
    </UserProvider>
  );
}
