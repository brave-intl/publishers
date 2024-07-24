'use client';

import Button from '@brave/leo/react/button';
import Input from '@brave/leo/react/input';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';
import PublicChannelPage from '../../../c/[public_identifier]/PublicChannelPage'

export default function Preview({channel}) {
  const t = useTranslations();
  const [isBannerFormat, setIsBannerFormat] = useState(true);
  const title = channel.details.publication_title
  const social = t(`contribution_pages.channel_names.${channel.details_type.split('ChannelDetails').join('').toLowerCase()}`);

  async function fetchChannelData() {
    const channelId = channel.id;
    console.log(channel)
    
  }

  useEffect(() => {
    fetchChannelData();
  }, []);

  return (
    <div className='mx-auto container py-4'>
      <h3 className='mb-4 pl-4'>{t('contribution_pages.preview_title', {social, title})}</h3>
      <PublicChannelPage publicIdentifier={channel.public_identifier} previewMode={true} />
    </div>
  );
}
