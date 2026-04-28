import Link from '@brave/leo/react/link';
import Image from 'next/image';
import Head from 'next/head';

import { useTranslations } from 'next-intl';
import { getTranslations } from 'next-intl/server';

import { siteConfig } from '@/constant/config';
import styles from '@/styles/PublicLayout.module.css';
import Logo from '~/images/brave_creators_logo.png';
import DarkLogo from '~/images/brave_logo_dark_bg.png';

export async function generateMetadata({ params }) {
  const {locale} = await params;
  const t = await getTranslations({ locale, namespace: 'metadata' });

  return {
    title: {
      absolute: `${t('public_title')} - ${t('title')}`,
    },
    openGraph: {
      url: siteConfig.url,
      title: `${t('public_title')} - ${t('title')}`,
      description: t('description'),
      siteName: t('title'),
      type: 'website',
      locale: 'en_US',
    },
    twitter: {
      card: 'summary_large_image',
      title: `${t('public_title')} - ${t('title')}`,
      description: t('description'),
    },
  };
}

export default function PublicChannelLayout({ children }) {
  const t = useTranslations();

  return (
    <div className='flex h-screen flex-col'>
      <div className={`${styles['header']}`}>
        <div className='container mx-auto'>
          <Image
            src={Logo}
            alt='Brave Creators Logo'
            priority={true}
            width={150}
          />
        </div>
      </div>
      <div className='flex-grow'>{children}</div>
      <div className={`${styles['footer']} small-regular`}>
        <div className='container mx-auto flex justify-between'>
          <div className='flex'>
            <Image
              src={DarkLogo}
              alt='Brave Logo'
              priority={true}
              width={110}
              className='self-center'
            />
          </div>
          <div className='text-right'>
            <div>
              <a
                className={`${styles['footer-link']}`}
                rel='noopener'
                href='https://basicattentiontoken.org/publisher-terms-of-service/'
              >
                {t('shared.terms_of_use')}
              </a>
              <span className={`${styles['footer-divider']}`}>/</span>
              <a
                className={`${styles['footer-link']}`}
                rel='noopener'
                href='https://hackerone.com/brave?type=team'
              >
                {t('shared.security_issue')}
              </a>
            </div>
            <div>
              <a
                className={`${styles['footer-link']}`}
                rel='noopener'
                href='https://brave.com/'
              >
                {t('shared.brave_copyright')}
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
