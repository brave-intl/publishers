'use client';

import { useEffect, useRef } from 'react';
import { useTranslations } from 'next-intl';
import styles from '@/styles/PublicChannelPage.module.css';
import Icon from '@brave/leo/react/icon';
import qr_logo from "~/images/qr_logo.png";
import QRCodeStyling from "qr-code-styling";

const qrCode = new QRCodeStyling({
          width: 270,
          height: 270,
          image: qr_logo.src,
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

export default function QRCodeModal({address, chain, displayChain}) {
  const t = useTranslations();
  const ref = useRef(null);

  useEffect(() => {
    if(typeof window !== 'undefined') {
      qrCode.append(ref.current);
    }
  }, []);

  useEffect(() => {
    qrCode.update({
      data: address
    });
  }, [address]);
  
  return (
    <div>
      <div className={`${styles['qr-title']}`}>
        <h2>{t('publicChannelPage.QRModalHeader')}</h2>
          {displayChain.includes('BAT') ? (
            <div className={`${styles['qr-subtitle']} default-regular`}>{t('publicChannelPage.QRBatText', {chain: t(`publicChannelPage.${chain}`)})}</div>
          ) : (
            <div className={`${styles['qr-subtitle']} default-regular`}>{t('publicChannelPage.QRStandardText', {chain})}</div>
          )}
      </div>
      <div id="qr-wrapper" ref={ref} className={`text-center ${styles['qr-box']}`}></div>
      <div className={`${styles['qr-text']}`}>
        <div className={`${styles['qr-text-item']}`}>
          <Icon name='smartphone-laptop' className={`${styles['qr-text-icon']} pr-3 color-interactive`} />
        </div>
        <div className={`${styles['qr-text-item']}`}>
          {t('publicChannelPage.QRModalText')}
        </div>
      </div>
    </div>
  )
}
