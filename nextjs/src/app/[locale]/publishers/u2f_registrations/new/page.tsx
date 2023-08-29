'use client';

import Button from '@brave/leo/react/button';
import Head from 'next/head';
import Link from 'next/link';
import * as React from 'react';

import Card from '@/components/Card';

export default function U2fRegistrations() {
  return (
    <main className='main'>
      <section className='content-width-sm'>
        <Card>
          <h1>Register Security Key</h1>
          <div className='mt-2'>INPUT GOES HERE</div>

          <div className='mt-4 flex justify-between'>
            <div className='flex w-[120px]'>
              <Button>Add</Button>
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
