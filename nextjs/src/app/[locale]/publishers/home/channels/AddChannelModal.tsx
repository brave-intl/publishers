'use client';

import Icon from '@brave/leo/react/icon';
import axios from 'axios';
import { useTranslations } from 'next-intl';

import styles from '@/styles/ChannelCard.module.css';

export default function AddChannelModal() {
  const t = useTranslations();
  const channels = ['website', 'youtube', 'twitch', 'x', 'vimeo', 'reddit'];

  function capitalizeFirstLetter(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  async function addChannel(channel) {
    axios.defaults.xsrfCookieName = 'CSRF-TOKEN';
    axios.defaults.xsrfHeaderName = 'X-CSRF-Token';
    axios.defaults.withCredentials = true;

    if (channel === 'website') {
      window.location.pathname = '/site_channels/new';
    } else if (channel === 'x') {
      const response = await axios({
        method: 'POST',
        url: '/publishers/auth/register_twitter_channel',
      });
      window.location = response.data.auth_url;
    } else {
      const response = await axios({
        method: 'POST',
        url: `/publishers/auth/register_${channel}_channel`,
      });
      window.location = response.data.auth_url;
    }
  }

  return (
    <div>
      <h3 className='pb-5'>{t('Home.channels.add_channel')}</h3>
      <p className='pb-2'>{t('Home.channels.add_channel_prompt')}</p>
      <section className='grid gap-2 md:grid-cols-3'>
        {channels.map(function (channel) {
          return (
            <div
              id={`add-${channel}`}
              className={`text-center ${styles['add-channel-card']}`}
              key={channel}
              onClick={() => addChannel(channel)}
            >
              <Icon
                className='mx-auto mb-2 inline-block'
                forceColor={true}
                name={channel === 'website' ? 'globe' : `social-${channel}`}
              />
              <h4 className='pb-1'>{capitalizeFirstLetter(channel)}</h4>
              <p className='color-tertiary small-regular'>
                {t(`Home.channels.${channel}_prompt`)}
              </p>
            </div>
          );
        })}
      </section>
    </div>
  );
}
