'use client';

import Button from '@brave/leo/react/button';
import Head from 'next/head';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import * as React from 'react';

import Card from '@/components/Card';

export default function U2fRegistrations() {
  const t = useTranslations();

  return (
    <main className='main'>
      <Head>
        <title>Register Key</title>
      </Head>
      <section className='content-width-sm'>
        <Card>
          <h1>{t('u2f_registrations.new.heading')}</h1>
          <div className='mt-2'>INPUT GOES HERE</div>

          <div className='mt-4 flex justify-between'>
            <div className='flex w-[120px]'>
              <Button>{t('u2f_registrations.new.submit_value')}</Button>
            </div>
            <div className='flex w-[120px]'>
              <Link href='../security'>
                <Button kind='plain'>
                  {t('totp_registrations.new.cancel')}
                </Button>
              </Link>
            </div>
          </div>
        </Card>
      </section>
    </main>
  );
}
