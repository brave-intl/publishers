'use client';

import Button from '@brave/leo/react/button';
import Image from 'next/image';
import { useTranslations } from 'next-intl';

import Card from '@/components/Card';

import Graphic from '~/images/channels_graphic.png';

export default function EmptyChannelCard({ addChannel }) {
  const t = useTranslations();

  return (
    <Card className='max-w-[364px] text-center'>
      <Image
        src={Graphic}
        alt='Channel Options'
        priority={true}
        width={148}
        className='mx-auto'
      />
      <h3 className='pb-1 pt-3'>{t('Home.channels.add_channel_title')}</h3>
      <p>{t('Home.channels.add_channel_prompt')}</p>
      <Button onClick={() => addChannel(true)} className='mt-3'>
        {t('Home.channels.add_first_channel')}
      </Button>
    </Card>
  );
}
