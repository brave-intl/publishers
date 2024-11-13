'use client';

import Button from '@brave/leo/react/button';
import { useTranslations } from 'next-intl';
import styles from '@/styles/ChannelCard.module.css';

export default function DisconnectConfirmationModal({ close, provider }) {
  const t = useTranslations();

  return (
    <div>
      <h1 className={styles['privacy-header']}>{t('walletServices.disconnectModal.title')}</h1>
      <p className={styles['privacy-text']}>{t('walletServices.disconnectModal.text', { provider: provider })}</p>
      <p className={styles['privacy-text']}>{t('walletServices.disconnectModal.textLine2')}</p>
      <div className="text-right">
        <div className={styles['privacy-button-container']}>
          <Button
            onClick={close}
            style={{ margin: '10px 0px', width: '320px' }}
            kind='outline'
          >
            {t('shared.cancel')}
          </Button>
        </div>
        <div className={styles['privacy-button-container']}>
          <Button
            onClick={() => {close(provider)}}
            style={{ margin: '10px 0px', width: '320px' }}
            kind='filled'
          >
            {t('walletServices.disconnectModal.confirmDisconnect')}
          </Button>
        </div>
      </div>
    </div>
  )
}
