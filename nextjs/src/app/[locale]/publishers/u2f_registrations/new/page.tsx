'use client';

import Button from '@brave/leo/react/button';
import Input from '@brave/leo/react/input';
import {
  create,
  parseCreationOptionsFromJSON,
} from '@github/webauthn-json/browser-ponyfill';
import Head from 'next/head';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';

export default function U2fRegistrations() {
  const t = useTranslations();
  const { push } = useRouter();
  const [name, setName] = useState('');
  const [webauthn, setWebauthn] = useState();
  const [isWaitingForKey, setIsWaitingForKey] = useState(false);

  async function fetchWebAuthResponse() {
    const data = await apiRequest('u2f_registrations/new');
    setWebauthn(data);
  }

  async function register({ user, challenge, excludeCredentials }) {
    const body = parseCreationOptionsFromJSON({
      publicKey: {
        challenge: challenge,
        rp: { name: '' },
        user: {
          id: user.id,
          name: user.name,
          displayName: user.displayName,
        },
        pubKeyCredParams: [{ type: 'public-key', alg: -7 }],
        excludeCredentials: excludeCredentials.map((x) => ({
          id: x.id,
          type: 'public-key',
        })),
        authenticatorSelection: { userVerification: 'discouraged' },
        extensions: {
          credProps: true,
        },
      },
    });
    return await create(body);
  }

  useEffect(() => {
    fetchWebAuthResponse();
  }, []);

  function handleInputChange(e) {
    setName(e.value);
  }

  async function handleSubmit() {
    setIsWaitingForKey(true);

    const webauthn_response = await register(webauthn).finally(() =>
      setIsWaitingForKey(false),
    );

    const response = await apiRequest('u2f_registrations/create', 'POST', {
      u2f_registration: {
        name,
      },
      webauthn_response: JSON.stringify(webauthn_response),
    });

    if (!response.errors) {
      push('/publishers/security');
    }
  }

  return (
    <main className='main'>
      <Head>
        <title>Register Key</title>
      </Head>
      <Container>
        <Card>
          <div className='max-w-screen-md'>
            <h1>{t('u2f_registrations.new.heading')}</h1>
            <div className='mt-2'>
              <Input
                onInput={handleInputChange}
                placeholder='Enter a nickname for the security key'
              >
                {t('activerecord.attributes.u2f_registration.name')}
              </Input>
            </div>

            <div className='mt-3 flex justify-between'>
              <div className='flex w-[120px]'>
                <Button onClick={handleSubmit}>
                  {t('u2f_registrations.new.submit_value')}
                </Button>
              </div>
              <div className='px-1'>
                <Link href='../security'>
                  <Button kind='plain'>
                    {t('totp_registrations.new.cancel')}
                  </Button>
                </Link>
              </div>
            </div>
            {isWaitingForKey && (
              <div className='mt-3'>
                <h3>{t('u2f_registrations.new.waiting_heading')}</h3>
                <div>{t('u2f_registrations.new.waiting_description')}</div>
              </div>
            )}
          </div>
        </Card>
      </Container>
    </main>
  );
}
