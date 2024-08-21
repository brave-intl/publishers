'use client';

import { useEffect } from 'react';
import { useTranslations } from 'next-intl';
import styles from '@/styles/PublicChannelPage.module.css';
import Icon from '@brave/leo/react/icon';
import qr_logo from "~/images/qr_logo.png";

export default function QRCodeModal({address, chain, displayChain}) {
  const t = useTranslations();

  useEffect(() => {
    createQRCode();
  }, []);

  function createQRCode() {
    if(typeof window !== 'undefined') {
      import('qr-code-styling').then(( QRCodeStyling ) => {
        const qrCode = QRCodeStyling({
          width: 270,
          height: 270,
          data: address,
          image: qr_logo,
          dotsOptions: {
            color: "#000000",
            type: "dots"
          },
          imageOptions: {
            crossOrigin: "anonymous",
            margin: 3
          },
          cornersSquareOptions: {
            type: 'extra-rounded'
          },
          cornersDotOptions: {
            type: 'square'
          }
        });

        qrCode.append(window.document.getElementById('qr-wrapper'));
      });
    }
  }
  
  return (
    <div>
      <div className={`${styles['qr-title']}`}>
        {t('publicChannelPage.QRModalHeader')}
          {displayChain.includes('BAT') ? (
            <div className={`${styles['qr-subtitle']}`}>{t('publicChannelPage.QRBatText', {chain: t(`publicChannelPage.${chain}`)})}</div>
          ) : (
            <div className={`${styles['qr-subtitle']}`}>{t('publicChannelPage.QRStandardText', {chain})}</div>
          )}
      </div>
      <div id="qr-wrapper" className={`text-center ${styles['crypto-option']}`}></div>
      <div className={`${styles['qr-text']}`}>
        <div className={`${styles['qr-text-item']}`}>
          <Icon name='smartphone-laptop' className="pr-3"/>
        </div>
        <div className={`${styles['qr-text-item']}`}>
          {t('publicChannelPage.QRModalText')}
        </div>
      </div>
    </div>
  )
}
