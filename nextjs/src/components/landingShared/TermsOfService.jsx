'use client';

import { useState } from "react";
import { useTranslations } from 'next-intl';
import styles from '@/styles/LandingPages.module.css';

export default function TermsOfService() {
  const t = useTranslations();
  const [checked, setChecked] = useState(false);
  const [checkBoxError, setCheckBoxError] = useState(false);

  return (
    <span className="text-white opacity-80 text-center text-[18px]">
      {t.rich('landingPages.main.termsOfService.description', {
        link: (chunks) => <a className="underline" rel="noopener" href="https://brave.com/publishers-creators-privacy/#brave-rewards">{chunks}</a>
      })}

      <div className="text-left my-[24px] p-[12px] flex flex-row">
        <input
          required
          name="terms_of_service"
          type="checkbox"
          checked={checked}
          className={`${styles['tos-input']}`}
          onChange={event => {
            setChecked(event.target.checked);
            setCheckBoxError(!event.target.checked)
          }}
          label={t("landingPages.main.termsOfService.agree")}
        />
        <span>
          {t("landingPages.main.termsOfService.agree")}
        </span>
      </div>

      {checkBoxError && (
        <p className={`${styles['login-errors']}`}>
          {t('landingPages.main.termsOfService.invalid')}
        </p>
      )}
    </span>
  );
};