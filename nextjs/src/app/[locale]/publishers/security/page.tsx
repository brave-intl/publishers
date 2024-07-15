'use client';

import Alert from '@brave/leo/react/alert';
import Button from '@brave/leo/react/button';
import Dialog from '@brave/leo/react/dialog';
import Icon from '@brave/leo/react/icon';
import clsx from 'clsx';
import moment from 'moment';
import Head from 'next/head';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';

import PhoneOutline from '~/images/phone_outline.svg';
import USBOutline from '~/images/usb_outline.svg';

export default function SecurityPage() {
  const [modal, setModal] = useState({ isOpen: false, id: null });
  const [isLoading, setIsLoading] = useState(true);
  const [security, setSecurity] = useState({
    u2f_registrations: [],
    u2f_enabled: false,
    totp_enabled: false,
  });
  const two_factor_enabled = security.u2f_enabled || security.totp_enabled;
  const { u2f_registrations, totp_enabled } = security;
  const t = useTranslations();

  useEffect(() => {
    fetchsecurity();
  }, []);

  async function fetchsecurity() {
    const res = await apiRequest(`/publishers/secdata`);
    setIsLoading(false);
    setSecurity(res);
  }

  async function removeSecurityKey() {
    const id = modal.id;

    const res = await apiRequest(`u2f_registrations/destroy`, 'DELETE', { id });

    if (!res.errors) {
      const newRegistrations = u2f_registrations.filter((k) => k.id !== id);
      setModal({ isOpen: false, id: null });
      setSecurity({
        ...security,
        u2f_registrations: newRegistrations,
        u2f_enabled: !!newRegistrations.length,
      });
    }
  }

  async function removeTotp() {
    const res = await apiRequest(`totp_registrations/destroy`, 'DELETE');

    if (!res.errors) {
      setModal({ isOpen: false, id: null });
      setSecurity({
        ...security,
        totp_enabled: false,
      });
    }
  }

  function getStatusText() {
    if (modal.id === 'totp') {
      return security.u2f_enabled ? 'Hardware Security Key' : 'None';
    } else {
      return security.totp_enabled ? 'Authenticator app on your phone' : 'None';
    }
  }

  return isLoading ? null : (
    <main className='main'>
      <Head>
        <title>{t('NavDropdown.security')}</title>
      </Head>
      <Container>
        <Card className='w-full'>
          <div className='max-w-screen-md'>
            <div className='mb-3 flex flex-col items-start justify-between md:flex-row'>
              <div className='md:w-[80%]'>
                <h1 className='mb-2'>{t('security.index.heading')}</h1>
                <div className='md:order-2'>{t('security.index.intro')}</div>
              </div>
              <div className='mt-2 text-white md:mt-0.5'>
                <div
                  className={clsx(
                    'flex items-start gap-0.5 rounded py-1 text-[18px] font-semibold',
                    {
                      'text-green': two_factor_enabled,
                      'text-red-30': !two_factor_enabled,
                    },
                  )}
                >
                  {two_factor_enabled && <Icon name='check-circle-outline' />}
                  {!two_factor_enabled && <Icon name='shield-disable' />}
                  {two_factor_enabled
                    ? t('security.index.enabled_yes')
                    : t('security.index.enabled_no')}
                </div>
              </div>
            </div>

            <hr className='my-4' />

            <div className='mb-3 mt-4 flex flex-col justify-between md:flex-row '>
              <div className='md:w-[80%]'>
                <h3 className='mb-2'>{t('security.index.totp.heading')}</h3>
                <div className='md:order-2'>{t('security.index.totp.intro')}</div>
                {!totp_enabled && (
                  <Alert type='info' className='mt-2'>
                    {t('security.index.totp.disabled_without_fallback_html')}
                  </Alert>
                )}
                {totp_enabled && (
                  <div className='mt-2'>
                    <span className='text-green font-medium'>
                      {t('security.index.totp.enabled')}
                    </span>
                    {' | '}
                    <span
                      className='cursor-pointer font-semibold text-blue-40'
                      onClick={() => setModal({ isOpen: true, id: 'totp' })}
                    >
                      {t('shared.remove')}
                    </span>
                  </div>
                )}
              </div>
              <div className='flex-start mt-2 flex-col items-center md:mt-0 md:flex md:pl-5'>
                <Link href='./totp_registrations/new'>
                  <Button
                    className='w-[150px] flex-grow-0'
                    kind={totp_enabled ? 'outline' : 'filled'}
                  >
                    {totp_enabled ? 'Reconfigure' : t('security.index.setup')}
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
                {!!security.u2f_registrations.length && (
                  <div className='mt-2'>
                    {security.u2f_registrations.map((item) => {
                      return (
                        <div key={item.id} className='mt-1'>
                          <span className='text-green font-medium'>
                            {`${item.name} `}
                          </span>
                          <span className='italic'>
                            {`registered on `}
                            {moment(item.created_at).format('MMMM D, YYYY')}
                          </span>
                          {' | '}
                          <span
                            className='cursor-pointer font-semibold text-blue-40'
                            onClick={() =>
                              setModal({ isOpen: true, id: item.id })
                            }
                          >
                            {t('shared.remove')}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
              <div className='mt-3 flex-col items-center md:mt-0  md:flex md:pl-5'>
                <Link href='./u2f_registrations/new'>
                  <Button className='w-[150px] flex-grow-0'>
                    {t('security.index.u2f.button')}
                  </Button>
                </Link>
                <USBOutline className='mt-3 hidden h-[50px] w-[60px] md:block' />
              </div>
            </div>
          </div>
        </Card>
        <Dialog isOpen={modal.isOpen}>
          <div slot='title'>
            {modal.id === 'totp'
              ? 'Disable Authenticator App?'
              : 'Remove Security Key?'}
          </div>
          <div>
            {t('u2f_registrations.u2f_registration.confirm_disable.intro')}
          </div>
          <div className='font-semibold'>[{getStatusText()}]</div>
          <div className='mt-1'>
            {modal.id === 'totp'
              ? 'Authenticator app provides a good fallback method to log in to your account securely in the case that you lose the hardware security key.'
              : 'Removing this security key will effectively turn off the two-factor authentication for your account.'}
          </div>
          <div className='mt-1'>
            {modal.id === 'totp'
              ? 'Are you sure you want to disable authenticator app?'
              : 'Are you sure you want to remove this security key?'}
          </div>
          <div slot='actions'>
            <Button onClick={() => setModal({ isOpen: false, id: null })}>
              {t('u2f_registrations.u2f_registration.confirm_disable.deny')}
            </Button>
            <Button
              kind='outline'
              onClick={modal.id === 'totp' ? removeTotp : removeSecurityKey}
            >
              {modal.id === 'totp'
                ? 'Disable it for now'
                : 'Remove Security Key'}
            </Button>
          </div>
        </Dialog>
      </Container>
    </main>
  );
}
