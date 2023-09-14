'use client';

import Button from '@brave/leo/react/button';
import Head from 'next/head';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import * as React from 'react';

import Card from '@/components/Card';

export default function TOTPNewPage() {
  const t = useTranslations();

  return (
    <main className='main'>
      <Head>
        <title>Setup Authenticator</title>
      </Head>
      <section className='content-width-sm'>
        <Card>
          <div className='[&>*]:mb-2'>
            <h1>{t('totp_registrations.new.heading')}</h1>
            <div>1. {t('totp_registrations.new.step_1')}</div>
            <div>
              2. {t('totp_registrations.new.step_2')}{' '}
              {t('totp_registrations.new.step_2_alt')}
              <span>QR CODE GOES HERE</span>
            </div>
            <div>QR IMAGE</div>
            <div>3. {t('totp_registrations.new.step_3')}</div>
            <div>INPUT GOES HERE</div>
          </div>
          <div className='mt-4 flex justify-between'>
            <div className='flex w-[120px]'>
              <Button>{t('totp_registrations.new.submit_value')}</Button>
            </div>
            <div className='flex w-[120px]'>
              <Link href='../security'>
                <Button kind='plain'>{t('Settings.buttons.cancel')}</Button>
              </Link>
            </div>
          </div>
        </Card>
      </section>
    </main>
  );
}
