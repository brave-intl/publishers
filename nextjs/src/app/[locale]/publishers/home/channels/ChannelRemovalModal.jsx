'use client';

import Button from '@brave/leo/react/button';
import { useTranslations } from 'next-intl';
import styles from '@/styles/ChannelCard.module.css';

export default function ChannelRemovalModal({ close, removeChannel, channelId }) {
  const t = useTranslations();

  return (
    <div>
      <h1 className={styles['privacy-header']}>
        {t('Home.channels.remove_channel_modal.headline')}
      </h1>
      <p className={styles['privacy-text']}>
        {t('Home.channels.remove_channel_modal.confirmation')}
      </p>
      <div className='text-right'>
        <div className={styles['privacy-button-container']}>
          <Button
            onClick={close}
            style={{ margin: '10px 0px', width: '320px' }}
            kind='outline'
          >
            {t('Home.channels.remove_channel_modal.deny')}
          </Button>
        </div>
        <div className={styles['privacy-button-container']}>
          <Button
            onClick={() => {
              removeChannel();
              close();
            }}
            style={{ margin: '10px 0px', width: '320px' }}
            kind='filled'
            id={`channel_modal_delete_button_${channelId}`}
          >
            {t('Home.channels.remove_channel_modal.confirm')}
          </Button>
        </div>
      </div>
    </div>
  );
}
