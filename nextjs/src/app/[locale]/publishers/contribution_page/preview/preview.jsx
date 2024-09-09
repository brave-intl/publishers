'use client';

import Button from '@brave/leo/react/button';
import Input from '@brave/leo/react/input';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';
import PublicChannelPage from '../../../c/[public_identifier]/PublicChannelPage'

export default function Preview({ isOpen, channel}) {
  const t = useTranslations();
  const [isBannerFormat, setIsBannerFormat] = useState(true);
  const [isRendered, setIsRendered] = useState(false)
  const title = channel.details.publication_title
  const social = t(`contribution_pages.channel_names.${channel.details_type.split('ChannelDetails').join('').toLowerCase()}`);

  useEffect(() => {
    if (isOpen) {
      // Render the modal content when opened
      setIsRendered(true);
    } else {
      // Reset the render state when the modal is closed (to force the modal to show fresh data)
      setIsRendered(false);
    }
  }, [isOpen]);

  return isRendered ?  (
    <div className='mx-auto w-full min-w-[640px] md:min-w-[768px] lg:min-w-[1024px] xl:min-w-[1280px] min-h-[880px] container py-4'>
      <h3 className='mb-4 pl-4'>{t('contribution_pages.preview_title', {social, title})}</h3>
      <PublicChannelPage publicIdentifier={channel.public_identifier} previewMode={true} />
    </div>
  ) : null;
}
