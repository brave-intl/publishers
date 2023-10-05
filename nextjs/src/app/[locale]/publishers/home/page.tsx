'use client';

import Button from '@brave/leo/react/button';
// import Checkbox from '@brave/leo/react/checkbox';
// import Dialog from '@brave/leo/react/dialog';
// import Input from '@brave/leo/react/input';
// import Toggle from '@brave/leo/react/toggle';
import Head from 'next/head';

import Card from '@/components/Card';

import BraveIcon from '~/icons/brave-icon-release-color.svg';
// import { useRouter } from 'next/navigation';
// import { useTranslations } from 'next-intl';
// import { useContext, useState } from 'react';
// import * as React from 'react';
// import { apiRequest } from '@/lib/api';
// import UserContext from '@/lib/context/UserContext';
// import { UserType } from '@/lib/propTypes';
import Uphold from '~/icons/uphold-color.svg';
import TippingBanner from '~/images/tipping_banner.svg';

export default function SettingsPage() {
  // const { user, updateUser } = useContext(UserContext);
  // const { push } = useRouter();
  // const t = useTranslations();

  return (
    <main className='main'>
      <Head>
        <title>Home</title>
        hello
      </Head>
      <section className='content-width-lg'>
        <Card className='test mb-3'>
          <div className='relative z-10'>
            <h2 className='mb-3'>Account Services</h2>
            <div className='flex gap-2'>
              <Card inner className='w-[40%]'>
                <div className='text-text-secondry mb-1'>
                  Connected custodian
                </div>
                <div className='flex h-[35px] items-end justify-between font-semibold'>
                  <div>
                    <Uphold className='mr-0.5 inline h-[24px] w-[24px]' />
                    Uphold
                  </div>
                  <div className=' text-red-30'>Disconnect</div>
                </div>
              </Card>
              <Card inner className='flex grow justify-between'>
                <div className='w-2/6'>
                  <div className='text-text-secondry mb-1'>Balance</div>
                  <div className='mb-1 flex h-[35px] items-end'>
                    <div>
                      <span className='text-[20px] font-semibold'>0.00 </span>
                      <span>BAT</span>
                    </div>
                  </div>
                </div>
                <div className='w-2/6'>
                  <div className='text-text-secondry mb-1'>Last Deposit</div>
                  <div className='mb-1 flex h-[35px] items-end'>
                    Sep 13th, 2022
                  </div>
                </div>
                <div className='w-2/6'>
                  <div className='text-text-secondry mb-1'>Next Deposit</div>
                  <div className='mb-1 flex h-[35px] items-end'>
                    Aug 15th, 2022
                  </div>
                </div>
              </Card>
            </div>
          </div>
        </Card>
        <Card className='flex items-center justify-between'>
          <div className='flex items-center'>
            <TippingBanner className='h-[143px] w-[192px]' />
            <div className='mx-5 '>
              <h3 className='mb-3'>Profile page and gift banner</h3>
              <div className='text-text-secondry max-w-[500px]'>
                Customize your profile page and social media banner to give your
                creator's profile an unique look.
              </div>
            </div>
          </div>
          <div className='flex w-[120px] justify-end'>
            <Button>Customize</Button>
          </div>
        </Card>
        <Card className='mt-3'>
          <h2 className='mb-2'>Channels</h2>
          <div>
            Link your social media accounts so we can show your status as a
            verified creator on the Brave browser, and enable tipping directly
            from your social media account pages.
          </div>
          <div className='mt-5 grid grid-cols-1 gap-2 sm:grid-cols-2 md:grid-cols-3'>
            {[0, 1, 2, 3, 4].map((i) => (
              <Card border inner className='flex justify-between' key={i}>
                <div>
                  <div className='flex items-center'>
                    <BraveIcon className='mr-0.5 h-[16px] w-[16px]' /> Website
                  </div>
                  <div className='text-text-secondry mt-0.5 text-[16px] font-semibold'>
                    Blog
                  </div>
                  <div className='text-text-secondry mt-2 font-semibold'>
                    CONTRIBUTIONS
                  </div>
                  <div className='text-[22px] font-medium'>
                    {'533.532 '}
                    <span className='text-text-secondry align-middle text-[12px] font-semibold'>
                      BAT
                    </span>
                  </div>

                  <Button className='mt-2' kind='plain'>
                    Remove
                  </Button>
                </div>
                <div className='bg-green-20 flex h-[20px] items-center rounded-4 p-0.5'>
                  <span className='text-green-50 text-[10px] font-semibold'>
                    VERIFIED
                  </span>
                </div>
              </Card>
            ))}
          </div>
        </Card>
      </section>
    </main>
  );
}
