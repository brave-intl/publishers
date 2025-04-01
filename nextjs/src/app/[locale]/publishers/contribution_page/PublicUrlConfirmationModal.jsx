'use client';

import Button from '@brave/leo/react/button';
import { useTranslations } from 'next-intl';
import styles from '@/styles/ChannelCard.module.css';

export default function PublicUrlConfirmationModal({ close, save, oldUrl, newUrl, baseUrl }) {
  const t = useTranslations();

  return (
    <div>
      <p className={styles['privacy-text']}>{t('contribution_pages.confirmation_text')}</p>
      <ol className={`${styles['ordered-list']} ml-3`}>
        <li className='mt-1'>{t('contribution_pages.confirmation_text_bullet_1')}</li>
        <li className='mt-1'>{t('contribution_pages.confirmation_text_bullet_2')}</li>
      </ol>
      <p className={'large-regular mt-2'}>{t('contribution_pages.confirmation_url_change_from')}</p>
      <p className='ml-2'>{baseUrl}<strong>{oldUrl}</strong></p>
      <p className={'large-regular mt-1'}>{t('contribution_pages.confirmation_url_change_to')}</p>
      <p className='ml-2'>{baseUrl}<strong>{newUrl}</strong></p>
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
