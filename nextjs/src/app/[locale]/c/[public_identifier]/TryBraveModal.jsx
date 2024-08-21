'use client';

import { useEffect } from 'react';
import { useTranslations } from 'next-intl';
import styles from '@/styles/PublicChannelPage.module.css';
import Icon from '@brave/leo/react/icon';
import wallet from "~/images/wallet_icon_color.png";

export default function TryBraveModal() {
  const t = useTranslations();

  return (
    <div className={`${styles['try-brave-background']}`}>
      <div className={`${styles['try-brave-header-section']}`}>
        <div className={`inline-block ${styles['try-brave-icon']}`}>
          <img className={`${styles['try-brave-image']}`} src={wallet}/>
        </div>
        <div className='inline-block'>
          <div className={`${styles['try-brave-header']}`}>
            {t('publicChannelPage.tryBraveHeader')}
          </div>
          <div className={`${styles['try-brave-subheader']}`}>
            {t('publicChannelPage.tryBraveSubheader')}
          </div>
        </div>
      </div>
      <div className={`${styles['try-brave-text']}`}>
        {t('publicChannelPage.tryBraveText')}
      </div>
      <div className={`${styles['try-brave-bullet']}`}>
        <Icon name='check-circle-filled' className={`${styles['bullet-image']}`} />
        {t('publicChannelPage.tryBraveBullet1')}
      </div>
      <div className={`${styles['try-brave-bullet']}`}>
        <Icon name='check-circle-filled' className={`${styles['bullet-image']}`} />
        {t('publicChannelPage.tryBraveBullet2')}
      </div>
      <div className={`${styles['try-brave-bullet']}`}>
        <Icon name='check-circle-filled' className={`${styles['bullet-image']}`} />
        {t('publicChannelPage.tryBraveBullet3')}
      </div>
      <a className={`${styles['try-brave-button']}`} href="https://brave.com/wallet/" target="_blank">
        {t('publicChannelPage.tryBraveButton')}
      </a>
    </div>
  )
}
