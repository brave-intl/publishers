'use client';

import Button from '@brave/leo/react/button';
import { useTranslations } from 'next-intl';
import Card from '@/components/Card';
import Graphic from '~/images/channels_graphic.png';
import Image from 'next/image';

export default function EmptyChannelCard({ setIsAddChannelModalOpen }) {
  const t = useTranslations();

  return (
    <Card className='text-center max-w-[364px]'>
      <Image
        src={Graphic}
        alt='Channel Options'
        priority={true}
        width={148}
        className='mx-auto'
      />
      <h3 className='pt-3 pb-1'>{t('Home.channels.add_channel_title')}</h3>
      <p>{t('Home.channels.add_channel_prompt')}</p>
      <Button onClick={()=>setIsAddChannelModalOpen(true)} className='mt-3'>{t('Home.channels.add_first_channel')}</Button>
    </Card>
  );
}
