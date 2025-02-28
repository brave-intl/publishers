'use client';

import Button from '@brave/leo/react/button';
import { useTranslations } from 'next-intl';
import styles from '@/styles/ChannelCard.module.css';

export default function PublicUrlConfirmationModal({ close, save }) {
  const t = useTranslations();

  return (
    <div>
      <p className={styles['privacy-text']}>{t('contribution_pages.confirmation_text')}</p>
      <ol className={`${styles['ordered-list']} ml-2`}>
        <li className='mt-1'>{t('contribution_pages.confirmation_text_bullet_1')}</li>
        <li className='mt-1'>{t('contribution_pages.confirmation_text_bullet_2')}</li>
      </ol>
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
            onClick={save}
            style={{ margin: '10px 0px', width: '320px' }}
            kind='filled'
          >
            {t('shared.continue')}
          </Button>
        </div>
      </div>
    </div>
  )
}
