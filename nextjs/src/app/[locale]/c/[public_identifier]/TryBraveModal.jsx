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
          <img className={`${styles['try-brave-image']}`} src={wallet.src}/>
        </div>
        <div className='inline-block'>
          <h2>{t('publicChannelPage.tryBraveHeader')}</h2>
          <div className='default-regular'>
            {t('publicChannelPage.tryBraveSubheader')}
          </div>
        </div>
      </div>
      <div className='default-regular pb-3 text-left'>
        {t('publicChannelPage.tryBraveText')}
      </div>
      <div className={`${styles['try-brave-bullet']} flex`}>
        <Icon name='check-circle-filled' className={`${styles['bullet-image']} color-interactive`} />
        <div className='pl-1'>{t('publicChannelPage.tryBraveBullet1')}</div>
      </div>
      <div className={`${styles['try-brave-bullet']} flex`}>
        <Icon name='check-circle-filled' className={`${styles['bullet-image']} color-interactive`} />
        <div className='pl-1'>{t('publicChannelPage.tryBraveBullet2')}</div>
      </div>
      <div className={`${styles['try-brave-bullet']} flex`}>
        <Icon name='check-circle-filled' className={`${styles['bullet-image']} color-interactive`} />
        <div className='pl-1'>{t('publicChannelPage.tryBraveBullet3')}</div>
      </div>
      <a className={`${styles['try-brave-button']}`} href="https://brave.com/wallet/" target="_blank">
        {t('publicChannelPage.tryBraveButton')}
      </a>
    </div>
  )
}
