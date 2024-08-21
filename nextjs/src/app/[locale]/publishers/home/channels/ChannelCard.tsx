'use client';

import Button from '@brave/leo/react/button';
import Hr from '@brave/leo/react/hr';
import Icon from '@brave/leo/react/icon';
import { useTranslations } from 'next-intl';
import { useContext,useEffect,useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import styles from '@/styles/ChannelCard.module.css';

import ChannelCryptoEditor from './ChannelCryptoEditor';

export default function ChannelCard({ channel, publisherId, onChannelDelete }) {
  const t = useTranslations();
  // TODO: come up with some default name
  const defaultName = '';

  async function removeChannel() {
    const response = await apiRequest(`channels/${channel.id}`, 'DELETE');
    if (response.errors) {
      // TODO show error state here
    } else {
      onChannelDelete(channel.id);
    }
  }

  function channelType() {
    return channel.details_type.split('ChannelDetails').join('').toLowerCase();
  }

  function channelDisplayType() {
    return t(`shared.channel_names.${channelType()}`);
  }

  function channelIconType() {
    if (channelType() === 'site') {
      return <Icon className={`color-interactive ${styles['channel-card-icon']}`} name='globe' />;
    } else if (channelType() === 'twitter') {
      return <Icon className={`${styles['channel-card-icon']}`} name='social-x' forceColor={true} />;
    } else {
      return <Icon className={`${styles['channel-card-icon']}`} name={`social-${channelType()}`} forceColor={true} />;
    }
  }

  function isUnverifiedChannel() {
    return !channel.verified && channelType() === 'site';
  }

  function displayVerified() {
    if (channel.verified) {
      return (
        <div className='flex items-center'>
          <span className='pr-0.5 small-regular'>{t('Home.channels.verified')}</span>
          <span className='inline-block'>
            <Icon className={`${styles['channel-verification-icon']}`} name='verification-filled-color' />
          </span>
        </div>
      );
    } else if (isUnverifiedChannel()) {
      return <div className='error-pill'>{t('Home.channels.incomplete')}</div>;
    } else {
      return (
        <div className='flex items-center'>
          <span className='pr-0.5 small-regular'>{t('Home.channels.not_verified')}</span>
          <span className='inline-block'>
            <Icon className={`color-tertiary ${styles['channel-verification-icon']}`} name='verification-filled-off' />
          </span>
        </div>
      );
    }
  }

  return (
    <Card id={channel.id} >
      <section className='flex justify-between pb-1'>
        <div className='flex items-center'>
          <span className='inline-block'>{channelIconType()}</span>
          <span className='small-semibold pl-1'>{channelDisplayType()}</span>
        </div>
        <div>{displayVerified()}</div>
      </section>
      <h3 className='pb-3 break-words'>{channel.details.publication_title || defaultName}</h3>
      <section className='pb-1'>
        {isUnverifiedChannel() ? (
          <div className='error-text mt-3'>
            <h4>{channel.failed_verification_details}</h4>
            <p>{channel.failed_verification_call_to_action}</p>
          </div>
        ) : (
          <ChannelCryptoEditor channel={channel} />
        )}
      </section>
      <Hr />
      <section className='pt-2 text-right self-end'>
        <Button id={`channel_row_delete_button_${channel.id}`} className='color-secondary mr-0.5' kind='plain-faint' onClick={removeChannel}>
          {t('shared.remove')}
        </Button>
        <Button href={`/publishers/contribution_page?channel=${channel.id}`} kind='outline'>{t('shared.customize')}</Button>
      </section>
    </Card>
  );
}
