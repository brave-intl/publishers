'use client';

import Alert from '@brave/leo/react/alert';
import Button from '@brave/leo/react/button';
import Icon from '@brave/leo/react/icon';
import Head from 'next/head';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import * as React from 'react';

import Card from '@/components/Card';

import PhoneOutline from '~/images/phone_outline.svg';
import USBOutline from '~/images/usb_outline.svg';

export default function SecurityPage() {
  const t = useTranslations();

  return (
    <main className='main'>
      <Head>
        <title>{t('NavDropdown.security')}</title>
      </Head>
      <section className='content-width'>
        <Card>
          <div className='mb-3 flex flex-col items-start justify-between md:flex-row'>
            <div className='md:w-[80%]'>
              <h1 className='mb-2'>{t('security.index.heading')}</h1>
              <div className='md:order-2'>{t('security.index.intro')}</div>
            </div>
            <div className='mt-2 text-white md:mt-0.5 md:pl-5'>
              <div className='flex items-center gap-0.5 rounded bg-green-30 px-2 py-1'>
                <Icon name='check-circle-outline' />
                {t('security.index.enabled_yes')}
              </div>
            </div>
          </div>

          <hr className='my-4' />

          <div className='mb-3 mt-4 flex flex-col justify-between md:flex-row '>
            <div className='md:w-[80%]'>
              <h3 className='mb-2'>{t('security.index.totp.heading')}</h3>
              <div className='md:order-2'>{t('security.index.totp.intro')}</div>
              <Alert type='info' className='mt-2'>
                {t('security.index.totp.disabled_without_fallback_html')}
              </Alert>
            </div>
            <div className='flex-start mt-2 flex-col items-center md:mt-0 md:flex md:pl-5'>
              <Link href='./totp_registrations/new'>
                <Button className='w-[150px] flex-grow-0'>
                  {t('security.index.setup')}
                </Button>
              </Link>
              <PhoneOutline className='mt-3 hidden h-[70px] w-[40px] md:block' />
            </div>
          </div>

          <hr className='my-4' />

          <div className='mb-3 mt-4 flex flex-col justify-between md:flex-row'>
            <div className='md:w-[80%]'>
              <h3 className='mb-2'>{t('security.index.u2f.heading')}</h3>
              <div className='md:order-2'>{t('security.index.u2f.intro')}</div>
              <div className='mt-2'>
                Nano!: registered on June 27, 2023 | Remove
              </div>
            </div>
            <div className='mt-2 flex-col items-center md:mt-0  md:flex md:pl-5'>
              <Link href='./u2f_registrations/new'>
                <Button className='w-[150px] flex-grow-0'>
                  {t('security.index.u2f.button')}
                </Button>
              </Link>
              <USBOutline className='mt-3 hidden h-[50px] w-[60px] md:block' />
            </div>
          </div>
        </Card>
      </section>
    </main>
  );
}
