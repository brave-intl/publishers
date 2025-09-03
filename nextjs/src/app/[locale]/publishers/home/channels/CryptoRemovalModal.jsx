'use client';

import Button from '@brave/leo/react/button';
import { useTranslations } from 'next-intl';
import styles from '@/styles/ChannelCard.module.css';

export default function CryptoRemovalModal({ close, clearAddress, address }) {
  const t = useTranslations();

  return (
    <div>
      <h1 className={styles['privacy-header']}>{t('Home.addCryptoWidget.removalHeader')}</h1>
      <p className={styles['privacy-text']}>{t('Home.addCryptoWidget.removalNotification')}</p>
      <div className="text-right">
        <div className={styles['privacy-button-container']}>
          <Button
            onClick={close}
            style={{ margin: '10px 0px', width: '320px' }}
            kind='outline'
          >
            {t('Home.addCryptoWidget.privacyQuit')}
          </Button>
        </div>
        <div className={styles['privacy-button-container']}>
          <Button
            onClick={() => {clearAddress(address); close()}}
            style={{ margin: '10px 0px', width: '320px' }}
            kind='filled'
          >
            {t('Home.addCryptoWidget.removalContinue')}
          </Button>
        </div>
      </div>
    </div>
  )
}
