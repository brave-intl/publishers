'use client';

import Alert from '@brave/leo/react/alert';
import Button from '@brave/leo/react/button';
import Input from '@brave/leo/react/input';
import Head from 'next/head';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useContext, useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';
import UserContext from '@/lib/context/UserContext';

import Card from '@/components/Card';
import NextImage from '@/components/NextImage';

export default function TOTPNewPage() {
  const t = useTranslations();
  const { push } = useRouter();
  const { user } = useContext(UserContext);
  const [hasErrors, setHasErrors] = useState(false);
  const [code, setCode] = useState('');
  const [totp, setTotp] = useState({
    registration: { secret: '' },
    qr_code_svg: '',
  });
  const formattedCode =
    totp?.registration?.secret.match(/.{4}/g)?.join(' ') || '';

  async function fetchTotp() {
    const data = await apiRequest('totp_registrations/new');
    setTotp(data);
  }
  useEffect(() => {
    fetchTotp();
  }, []);

  function handleInputChange(e) {
    setCode(e.value);
  }

  async function handleSubmit() {
    const response = await apiRequest('totp_registrations/create', 'POST', {
      totp_password: code,
      totp_registration: {
        secret: totp.registration.secret,
      },
    });
    if (response.errors) {
      setHasErrors(true);
    } else {
      push('/publishers/security');
    }
  }

  return (
    <main className='main'>
      <Head>
        <title>Setup Authenticator</title>
      </Head>
      <section className='content-width-sm mt-3 mb-3'>
        <Card>
          <div className='[&>*]:mb-2'>
            {user.two_factor_enabled && (
              <Alert type='warning'>
                {t('totp_registrations.new.warning')}
              </Alert>
            )}
            <h1>{t('totp_registrations.new.heading')}</h1>
            <div>1. {t('totp_registrations.new.step_1')}</div>
            <div>
              2. {t('totp_registrations.new.step_2')}
              <Alert className='mt-2' type='info'>
                <div className='italic'>
                  {t('totp_registrations.new.step_2_alt')}
                </div>
                <span className='font-semibold text-blue-40'>{` ${formattedCode}`}</span>
              </Alert>
            </div>
            <div>
              {totp.qr_code_svg && (
                <NextImage
                  className='border-primary box-content rounded-2 bg-white p-2'
                  useSkeleton
                  width='200'
                  height='200'
                  alt='qr_code'
                  src={`data:image/svg+xml;utf8,${encodeURIComponent(
                    totp?.qr_code_svg,
                  )}`}
                />
              )}
            </div>
            <div>3. {t('totp_registrations.new.step_3')}</div>
            <div className='sm:w-[300px]'>
              <Input
                placeholder='6-digit code'
                onInput={handleInputChange}
                showErrors={hasErrors}
              >
                <div slot='errors'>{t('shared.invalid_totp')}</div>
              </Input>
            </div>
          </div>
          <div className='mt-4 flex justify-between'>
            <div className='flex w-[120px]'>
              <Button onClick={handleSubmit} isDisabled={code.length !== 6}>
                {t('totp_registrations.new.submit_value')}
              </Button>
            </div>
            <span className='px-1'>
              <Link href='../security'>
                <Button kind='plain'>{t('Settings.buttons.cancel')}</Button>
              </Link>
            </span>
          </div>
        </Card>
      </section>
    </main>
  );
}
