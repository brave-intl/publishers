'use client';

import Button from '@brave/leo/react/button';
import Hr from '@brave/leo/react/hr';
import Icon from '@brave/leo/react/icon';
import { useTranslations } from 'next-intl';
import { useContext,useEffect,useState } from 'react';

import styles from '@/styles/ChannelCard.module.css';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';

import ChannelCryptoEditor from './ChannelCryptoEditor';

export default function ChannelCard({ channel, publisherPayable }) {
  const t = useTranslations();
  // TODO: come up with some default name
  const defaultName = '';

  useEffect(() => {
    console.log(channel);
  }, []);

  async function removeChannel() {
    const response = await apiRequest(`channels/${channel.id}`, 'DELETE');
    console.log(response);
  }

  function channelType() {
    return channel.details_type.split('ChannelDetails').join('').toLowerCase();
  }

  function channelDisplayType() {
    return t(`shared.channel_names.${channelType()}`);
  }

  function channelIconType() {
    if (channelType() === 'site') {
      return <Icon name='globe' />;
    } else if (channelType() === 'twitter') {
      return <Icon name='social-x' />;
    } else {
      return <Icon name={`social-${channelType()}`} />;
    }
  }

  function isUnverifiedChannel() {
    return !channel.verified && channelType() === 'site';
  }

  function displayVerified() {
    if (channel.verified && publisherPayable) {
      return (
        <div className='flex items-center'>
          <span className='pr-1'>{t('Home.channels.verified')}</span>
          <span className='inline-block'>
            <Icon name='verification-filled-color' />
          </span>
        </div>
      );
    } else if (isUnverifiedChannel()) {
      return <div>{t('Home.channels.incomplete')}</div>;
    } else {
      return (
        <div className='flex items-center'>
          <span className='pr-1'>{t('Home.channels.not_verified')}</span>
          <span className='inline-block'>
            <Icon name='verification-filled-off' />
          </span>
        </div>
      );
    }
  }

  return (
    <Card>
      <section className='flex justify-between'>
        <div className='flex items-center'>
          <span className='inline-block'>{channelIconType()}</span>
          <span className='pl-1'>{channelDisplayType()}</span>
        </div>
        <div>{displayVerified()}</div>
      </section>
      <div>{channel.details.publication_title || defaultName}</div>
      <section>
        {isUnverifiedChannel() ? (
          <div>
            <h4>{channel.failed_verification_details}</h4>
            <p>{channel.failed_verification_call_to_action}</p>
          </div>
        ) : (
          <ChannelCryptoEditor channel={channel} />
        )}
      </section>
      <Hr />
      <section>
        <Button kind='plain' onClick={removeChannel}>
          {t('shared.remove')}
        </Button>
        <Button kind='outline'>{t('shared.customize')}</Button>
      </section>
    </Card>
  );
}
