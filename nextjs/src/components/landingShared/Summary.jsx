'use client'

import Icon from '@brave/leo/react/icon';
import styles from '@/styles/LandingPages.module.css';
import SwoopBottom from "~/images/swoop-bottom.svg";
import SwoopTop from "~/images/swoop-top.svg";
import { useTranslations } from 'next-intl';

function TextBlock({ side, step, title, description }) {
  return (
    <div className={`${styles['box']} min-h-[initial] flex-row w-1/2 p-[24px] ${styles[side]}`}>
      <h1 className={`${styles['summary-number']}`}>
        {step}
      </h1>
      <div className="flex-[0 0 auto] self-stretch w-[12px] md:w-[16px]"></div>
      <div className={`${styles['box']} flex-col w-auto md:w-[480px]`}>
        <h3 className={`${styles['spotlight-heading']} text-white m-0`}>
          {title}
        </h3>
        <p className="text-[#E9E9F4] my-[1em] md:text-white w-max-[600px] md:text-[16px] leading-[1.6]">
          {description}
        </p>
      </div>
    </div>
  );
};

function CardButton({ href, icon, title }) {
  return (
    <a rel="noopener" href={href} className="inline-flex grow justify-center">
      <div className={`${styles['box']} ${styles['card-button']}`}>
        {icon}
        <div className="w-[16px]"></div>
        <p>
          {title}
        </p>
        <div className="w-[16px]"></div>
        <Icon name="carat-right" />
      </div>
    </a>
  );
};

export default function Summary() {
  const t = useTranslations();
  
  return (
    <div className={`${styles['gradient-background']} ${styles['box']} flex-col`}>
      <SwoopTop className="absolute top-[-2px] w-full" />
      <div className={`${styles['box']} h-[13vw] min-h-[100px]`} />
      <div className={`${styles['box']} w-full max-w-[1200px] flex-col px-[48px]`}>
        <h2 className={`${styles['summary-heading']}`}>
          {t("landingPages.summary.heading")}
        </h2>
        <TextBlock
          side="start"
          step="1"
          title={t("landingPages.summary.oneTitle")}
          description={t("landingPages.summary.oneDesc")}
        />
        <TextBlock
          side="end"
          step="2"
          title={t("landingPages.summary.twoTitle")}
          description={t("landingPages.summary.twoDesc")}
        />
        <TextBlock
          side="start"
          step="3"
          title={t("landingPages.summary.threeTitle")}
          description={t("landingPages.summary.threeDesc")}
        />
        <TextBlock
          side="end"
          step="4"
          title={t("landingPages.summary.fourTitle")}
          description={t("landingPages.summary.fourDesc")}
        />
        <div className="w-[70%] my-[24px] border border-solid border-[#ffffff26]" ></div>
        <div className={`${styles['box']} w-full flex-row my-[24px] justify-center`}>
          <CardButton
            href={t("landingPages.summary.cardBusinessHref")}
            icon={<Icon name="message-bubble-chat" className={`${styles['summary-icon']}`} />}
            title={t("landingPages.summary.cardBusiness")}
          />
          <CardButton
            href={t("landingPages.summary.cardHelpHref")}
            icon={<Icon name="help-outline" className={`${styles['summary-icon']}`} />}
            title={t("landingPages.summary.cardHelp")}
          />
        </div>
      </div>
      <div className={`${styles['box']} h-[13vw] min-h-[100px]`} />
      <SwoopBottom className="bottom-[-2px] absolute w-full z-0" />
    </div>
  );
};
