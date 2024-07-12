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
  const [isNavOpen, setIsNavOpen] = useState(false);

  useEffect(() => {
    setTheme(localStorage.getItem('theme') || 'auto');
    setRoute(window.location.pathname);
  }, []);

  function updateTheme(e) {
    setTheme(e.value);
    document.body.setAttribute('data-theme', e.value);
    localStorage.setItem('theme', e.value);
  }

  return (
    <UserProvider>
      <div className={`${isNavOpen ? 'hidden' : 'inline-block'} md:hidden grid grid-cols-6 ${styles['nav-mobile']}`}>
        <Button
          onClick={() => setIsNavOpen(true)}
          kind='plain-faint'
          className='col-span-1'
        >
          <Icon name='hamburger-menu'/>
        </Button>
        <div className='col-span-5 flex flex-row justify-center items-center'>
          <Image
            src={Logo}
            alt='Brave Creators Logo'
            priority={true}
            width={110}
            className='mr-[16%]'
          />
        </div>
      </div>
      <div className='flex-column flex'>
        <Navigation
          className={`${isNavOpen ? 'inline-block' : 'hidden'} md:inline-block max-w-[280px] min-w-[280px] ${styles['nav-background']}`}
        >
          <NavigationHeader>
            <Image
              src={Logo}
              alt='Brave Creators Logo'
              priority={true}
              width={110}
            />
            <Button 
              kind='plain-faint'
              onClick={()=> setIsNavOpen(false)}
              className='md:hidden'
            >
              <Icon name='close' className='absolute right-0 top-1'/>
            </Button>
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
              <Link href='https://brave.com/blog/on-chain-contributions/'>{t('shared.learn_more')}</Link>
              {' - '}
              <Link
                className='underline font-normal'
                onClick={() => {
                  setDismissCrypto(true);
                }}
              >
                {t('shared.dismiss')}
              </Link>
            </p>
          </div>
          <NavigationActions slot='actions'>
{/*            <div className={styles['theme-switcher']}>
              <span className={styles.theme}>Theme</span>
              <SegmentedControl size='tiny' value={theme} onChange={updateTheme}>
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
            </div>*/}
            <Hr />
            <div className='action-items'>
{/*              <NavigationItem
                outsideList={true}
                icon='help-outline'
                href='/faqs'
              >
                {t('NavDropdown.faqs')}
              </NavigationItem>*/}
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
        <div className={`${isNavOpen ? 'hidden' : 'inline-block'}`}>
          {children}
        </div>
        <div className={`${isNavOpen ? 'inline-block' : 'hidden'} bg-gray-400`}></div>
      </div>
    </UserProvider>
  );
}
