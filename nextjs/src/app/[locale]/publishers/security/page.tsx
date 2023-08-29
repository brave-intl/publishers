'use client';

import Alert from '@brave/leo/react/alert';
import Button from '@brave/leo/react/button';
import Icon from '@brave/leo/react/icon';
import Link from 'next/link';
import * as React from 'react';

import Card from '@/components/Card';

import PhoneOutline from '~/images/phone_outline.svg';
import USBOutline from '~/images/usb_outline.svg';

export default function SecurityPage() {
  return (
    <main className='main'>
      <section className='content-width'>
        <Card>
          <div className='mb-3 flex flex-col items-start justify-between md:flex-row'>
            <div className='md:w-[80%]'>
              <h1 className='mb-2'>Two Factor Authentication</h1>
              <div className='md:order-2'>
                Two-factor authentication (2FA) is a method of confirming your
                identity by using two different forms of verification when you
                access Brave Payments in order to increase security (recommended
                for protecting your account).
              </div>
            </div>
            <div className='mt-2 text-white md:mt-0.5 md:pl-5'>
              <div className='flex items-center gap-0.5 rounded bg-green-30 px-2 py-1'>
                <Icon name='check-circle-outline' /> Enabled
              </div>
            </div>
          </div>

          <hr className='my-4' />

          <div className='mb-3 mt-4 flex flex-col justify-between md:flex-row '>
            <div className='md:w-[80%]'>
              <h3 className='mb-2'>App on your phone</h3>
              <div className='md:order-2'>
                Use an app on your phone to get an authentication code. You will
                be asked to type in this code when logging in.
              </div>
              <Alert type='info' className='mt-2'>
                Recommended: Set up an authenticator as the secondary 2FA in
                case you run into a problem with the security key.
              </Alert>
            </div>
            <div className='flex-start mt-2 flex-col items-center md:mt-0 md:flex md:pl-5'>
              <Link href='./totp_registrations/new'>
                <Button className='w-[150px] flex-grow-0'>Set Up</Button>
              </Link>
              <PhoneOutline className='mt-3 hidden h-[70px] w-[40px] md:block' />
            </div>
          </div>

          <hr className='my-4' />

          <div className='mb-3 mt-4 flex flex-col justify-between md:flex-row'>
            <div className='md:w-[80%]'>
              <h3 className='mb-2'>Hardware security keys</h3>
              <div className='md:order-2'>
                Security key is a small device that connects to your computer
                via a USB port and works with FIDO Universal 2nd Factor (U2F).
                You will be asked to insert and press the key instead of typing
                in a code. *Currently, security key is supported by Brave,
                Google Chrome, and Opera. *A list of security keys that have
                been tested
              </div>
              <div className='mt-2'>
                Nano!: registered on June 27, 2023 | Remove
              </div>
            </div>
            <div className='mt-2 flex-col items-center md:mt-0  md:flex md:pl-5'>
              <Link href='./u2f_registrations/new'>
                <Button className='w-[150px] flex-grow-0'>Add Key</Button>
              </Link>
              <USBOutline className='mt-3 hidden h-[50px] w-[60px] md:block' />
            </div>
          </div>
        </Card>
      </section>
    </main>
  );
}
