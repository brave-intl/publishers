'use client';

import Button from '@brave/leo/react/button';
import Hr from '@brave/leo/react/hr';
import Icon from '@brave/leo/react/icon';
import { useTranslations } from 'next-intl';
import { useContext, useEffect } from 'react';

import styles from '@/styles/ChannelCard.module.css';

import { apiRequest } from '@/lib/api';
import { CustodianConnectionContext } from '@/lib/context/CustodianConnectionContext';
import { ChannelCardContext } from '@/lib/context/ChannelCardContext';
import Card from '@/components/Card';

import CustodianServiceWidget from '../custodianServices/CustodianServiceWidget';
import ChannelCryptoEditor from './ChannelCryptoEditor';

export default function ChannelCard({ channel, publisherId, onChannelDelete, custodianData }) {
  const t = useTranslations();
  // TODO: come up with some default name
  const defaultName = '';

  const {
      setBitflyerConnection,
      setUpholdConnection,
      setGeminiConnection,
      setAllowedRegions
  } = useContext(CustodianConnectionContext);

  const {
    hasCustodian,
    hasCrypto,
    setHasCustodian
  } = useContext(ChannelCardContext);

  useEffect(() => {
    setBitflyerConnection(custodianData.bitflyer_connection);
    setUpholdConnection(custodianData.uphold_connection);
    setGeminiConnection(custodianData.gemini_connection);

    setHasCustodian(custodianData.bitflyer_connection || custodianData.uphold_connection || custodianData.gemini_connection)
    setAllowedRegions(custodianData.allowed_regions);
  }, [])

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
      return (
        <Icon
          className={`color-interactive ${styles['channel-card-icon']}`}
          name='globe'
        />
      );
    } else if (channelType() === 'twitter') {
      return (
        <Icon
          className={`${styles['channel-card-icon']}`}
          name='social-x'
          forceColor={true}
        />
      );
    } else {
      return (
        <Icon
          className={`${styles['channel-card-icon']}`}
          name={`social-${channelType()}`}
          forceColor={true}
        />
      );
    }
  }

  function isUnverifiedChannel() {
    return !channel.verified && channelType() === 'site';
  }

  function displayVerified() {
    if (channel.verified && ( hasCrypto || hasCustodian )) {
      return (
        <div className='flex items-center'>
          <span className='small-regular pr-0.5'>
            {t('Home.channels.verified')}
          </span>
          <span className='inline-block'>
            <Icon
              className={`${styles['channel-verification-icon']}`}
              name='verification-filled-color'
            />
          </span>
        </div>
      );
    } else if (isUnverifiedChannel()) {
      return <div className='error-pill'>{t('Home.channels.incomplete')}</div>;
    } else {
      return (
        <div className='flex items-center'>
          <span className='small-regular pr-0.5'>
            {t('Home.channels.not_verified')}
          </span>
          <span className='inline-block'>
            <Icon
              className={`color-tertiary ${styles['channel-verification-icon']}`}
              name='verification-filled-off'
            />
          </span>
        </div>
      );
    }
  }

  return (
    <Card id={channel.id}>
      <section className='flex justify-between pb-1'>
        <div className='flex items-center'>
          <span className='inline-block'>{channelIconType()}</span>
          <span className='small-semibold pl-1'>{channelDisplayType()}</span>
        </div>
        <div>{displayVerified()}</div>
      </section>
      <h3 className='break-words pb-3'>
        {channel.details.publication_title || defaultName}
      </h3>
      <section>
        {isUnverifiedChannel() ? (
          <div className='error-text mt-3'>
            <h4>{channel.failed_verification_details}</h4>
            <p>{channel.failed_verification_call_to_action}</p>
          </div>
        ) : (
          <div className='pb-1'>
            <ChannelCryptoEditor channel={channel} />
            <CustodianServiceWidget custodianData={custodianData} />
          </div>
        )}
      </section>
      <Hr />
      <section className='self-end pt-2 text-right'>
        <Button
          id={`channel_row_delete_button_${channel.id}`}
          className='color-secondary mr-0.5'
          kind='plain-faint'
          onClick={removeChannel}
        >
          {t('shared.remove')}
        </Button>
        {hasCrypto && (
          <Button
            href={`/publishers/contribution_page?channel=${channel.id}`}
            kind='outline'
          >
            {t('shared.customize_contribution')}
          </Button>
        )}
      </section>
    </Card>
  );
}
