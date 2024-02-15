'use client';

import Icon from '@brave/leo/react/icon';
import axios from 'axios';
import { useTranslations } from 'next-intl';

export default function AddChannelModal() {
  const t = useTranslations();
  const channels = ['website', 'youtube', 'twitch', 'x', 'vimeo', 'reddit'];

  function capitalizeFirstLetter(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  async function addChannel(channel) {
    if (channel === 'website') {
      window.location.pathname = '/site_channels/new';
    } else if (channel === 'x') {
      const response = await axios({
        method: 'POST',
        url: '/publishers/auth/register_twitter_channel',
        data: {allow_other_host: true},
      });
      console.log(response);
    } else {
      window.location.pathname = `/publishers/auth/register_${channel}_channel`;
    }
  }

  return (
    <div>
      <h3>{t('Home.channels.add_channel')}</h3>
      <p>{t('Home.channels.add_channel_prompt')}</p>
      {channels.map(function (channel) {
        return (
          <div key={channel} onClick={() => addChannel(channel)}>
            <Icon
              name={channel === 'website' ? 'globe' : `social-${channel}`}
            />
            <h4>{capitalizeFirstLetter(channel)}</h4>
            <p>{t(`Home.channels.${channel}_prompt`)}</p>
          </div>
        );
      })}
    </div>
  );
}
