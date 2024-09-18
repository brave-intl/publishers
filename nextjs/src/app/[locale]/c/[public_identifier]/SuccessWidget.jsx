'use client';

import { useTranslations } from 'next-intl';
import styles from '@/styles/PublicChannelPage.module.css';

export default function SuccessWidget({setStateToStart, amount, chain, name}) {
  const t = useTranslations();
  const tweetText = t('publicChannelPage.successTweet', {url: window.location.href, name: name, symbol: chain});
  
  return (
    <div className={`${styles['success-wrapper']}`}>
      <div className={`${styles['success-message-wrapper']}`}>
        <div className={`${styles['success-amount']}`}>
          {t('publicChannelPage.hooray', {amount: `${amount} ${chain}`})}
        </div>
        <div className={`${styles['success-thank']}`}>
          {t('publicChannelPage.thanks')}
        </div>
      </div>
      <div className={`${styles['payment-buttons']}`}>
        <button
          className={`${styles['share-button']}`}
          href={`https://twitter.com/intent/tweet?text=${tweetText}`}
          target="_blank"
          rel="noopener noreferrer"
        >
          {t('publicChannelPage.share')}
        </button>
        
        <a 
          className={`${styles['qr-link']}`}
          onClick={(event) => {
            event.preventDefault();
            setStateToStart();
          }}
        >
          {t('publicChannelPage.goBack')}
        </a>
      </div>
    </div>
  )
}
