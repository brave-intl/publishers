'use client';

import styles from '@/styles/LandingPages.module.css';
import BuiltWithBat from "~/images/built-with-bat.jsx";
import { useLocale, useTranslations } from 'next-intl';

export default function Footer() {
  const t = useTranslations();
  const locale = useLocale();
  
  return (
    <div className={`${styles['box']} ${styles['footer']} py-[12px] sm:py-[24px] px-[24px] sm:px-[48px]`}>
      <div className={`${styles['box']} flex-row p-[8px] sm:p-0`}>
        <a rel="noopener" className="text-[12px] text-[#7c7d8c]" href={t("landingPages.footer.oneHref")}>
          {t("landingPages.footer.one")}
        </a>
        <div className="w-[12px]"></div>
        <p className="text-[14px] text-[#808080]">|</p>
        <div className="w-[12px]"></div>
        <a rel="noopener" className="text-[12px] text-[#7c7d8c]"  label={t("landingPages.footer.two")} href={t("landingPages.footer.twoHref")}>
          {t("landingPages.footer.two")} 
        </a>
        <div className="w-[12px]"></div>
        <p className="text-[14px] text-[#808080]">|</p>
        <div className="w-[12px]"></div>
        <a rel="noopener" className="text-[12px] text-[#7c7d8c]" href={t("landingPages.footer.threeHref")}>
          {t("landingPages.footer.three")} 
        </a>
      </div>
      {(locale !== 'ja') && (
        <a className={`${styles['box']} flex-row p-[8px] sm:p-0`}
          href={t("landingPages.footer.fourHref")}
          aria-label={t("nav.batPillAlt")}
        >
          <BuiltWithBat />
        </a>
      )}
    </div>
  );
};
