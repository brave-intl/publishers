'use client';

import Button from '@brave/leo/react/button';
import { useTranslations } from 'next-intl';
import styles from '@/styles/ChannelCard.module.css';

export default function CryptoPrivacyModal({ close, updateAddress, address }) {
  const t = useTranslations();

  return (
    <div>
      <h1 className={styles['privacy-header']}>{t('Home.addCryptoWidget.privacyHeader')}</h1>
      <p className={styles['privacy-text']}>{t('Home.addCryptoWidget.privacyNotification')}</p>
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
          onClick={() => {updateAddress(address); close()}}
          style={{ margin: '10px 0px', width: '320px' }}
          kind='plain'
        >
          {t('Home.addCryptoWidget.privacyContinue')}
        </Button>
      </div>
    </div>
  )
}
