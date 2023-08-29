'use client';

import Button from '@brave/leo/react/button';
import Head from 'next/head';
import Link from 'next/link';
import * as React from 'react';

import Card from '@/components/Card';

export default function TOTPNewPage() {
  return (
    <main className='main'>
      <section className='content-width-sm'>
        <Card>
          <div className='[&>*]:mb-2'>
            <h1>Set Up Authenticator App</h1>
            <div>1. Install an authenticator app on your mobile phone.</div>
            <div>
              2. Scan the QR code below with your app. If you can't scan the QR
              code, enter this code: <span>QR CODE GOES HERE</span>
            </div>
            <div>QR IMAGE</div>
            <div>
              3. Enter the 6-digit code from the app once the scan is complete.
            </div>
            <div>INPUT GOES HERE</div>
          </div>
          <div className='mt-4 flex justify-between'>
            <div className='flex w-[120px]'>
              <Button>Complete</Button>
            </div>
            <div className='flex w-[120px]'>
              <Link href='../security'>
                <Button kind='plain'>Cancel</Button>
              </Link>
            </div>
          </div>
        </Card>
      </section>
    </main>
  );
}
