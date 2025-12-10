'use client';

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import styles from '@/styles/LandingPages.module.css';

export default function TermsOfService() {
  const t = useTranslations();
  const [checked, setChecked] = useState(false);
  const [checkBoxError, setCheckBoxError] = useState(false);

  return (
    <span className='text-center text-[18px] text-white opacity-80'>
      {t.rich('landingPages.main.termsOfService.description', {
        link: (chunks) => (
          <a
            className='underline'
            rel='noopener'
            href='https://brave.com/publishers-creators-privacy/#brave-rewards'
          >
            {chunks}
          </a>
        ),
      })}

      <div className='my-[24px] flex flex-row p-[12px] text-left'>
        <input
          required
          name='terms_of_service'
          type='checkbox'
          checked={checked}
          className={`${styles['tos-input']}`}
          onChange={(event) => {
            setChecked(event.target.checked);
            setCheckBoxError(!event.target.checked);
          }}
          label={t('landingPages.main.termsOfService.agree')}
        />
        <span>{t('landingPages.main.termsOfService.agree')}</span>
      </div>

      {checkBoxError && (
        <p className={`${styles['login-errors']}`}>
          {t('landingPages.main.termsOfService.invalid')}
        </p>
      )}
    </span>
  );
}
