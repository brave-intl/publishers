'use client';

import { useEffect, useState } from 'react';
import styles from '@/styles/LandingPages.module.css';
import CreatorsWide_webp from '~/images/creator-logos-wide.webp';
import CreatorsWide_png from '~/images/creator-logos-wide.png';
import CreatorsMobile_webp from '~/images/creator-logos-mobile.webp';
import CreatorsMobile_png from '~/images/creator-logos-mobile.png';
import { useTranslations } from 'next-intl';

export default function Signoff() {
  const t = useTranslations();
  const [channelsCount, SetChannelsCount] = useState(1000000); // defaults to 1mil

  useEffect(() => {
    fetchTotalVerifiedChannels();
  }, []);

  async function fetchTotalVerifiedChannels() {
    try {
      const response = await fetch('/api/v3/public/channels/total_verified');
      const result = await response.json();

      SetChannelsCount(result);
    } catch (err) {
      console.error(err);
    }
  }

  return (
    <div className={`${styles['box']} flex-col`}>
      <div
        className={`${styles['box']} w-max-[1200px] w-full flex-col p-[48px]`}
      >
        <div className={`${styles['box']} flex-col px-[48px]`}>
          <h4 className={`${styles['signoff-heading']} my-[1.33em]`}>
            {t.rich('landingPages.signoff.headline', {
              strong: (chunks) => (
                <strong>
                  {channelsCount}
                  {chunks}
                </strong>
              ),
            })}
          </h4>
          <div
            className={`${styles['box']} md:px-48px col flex p-[24px] md:py-0`}
            pad='24px'
            id='signoff'
          >
            <img
              src={CreatorsWide_webp.src}
              onError={(e) => (e.currentTarget.src = CreatorsWide_png.src)}
              className='hidden flex-[1_1_0%] overflow-hidden object-contain md:block'
            />
            <img
              src={CreatorsMobile_webp.src}
              onError={(e) => (e.currentTarget.src = CreatorsMobile_png.src)}
              className='flex-[1_1_0%] overflow-hidden object-contain md:hidden'
            />
          </div>
        </div>
        <a
          className={`${styles['primary-button']} m-[48px]`}
          href={t('landingPages.signoff.btnHref')}
          name={t('landingPages.signoff.btn')}
        >
          {t('landingPages.signoff.btn')}
        </a>
      </div>
    </div>
  );
}
