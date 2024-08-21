'use client';

import styles from '@/styles/PublicChannelPage.module.css';
import Icon from '@brave/leo/react/icon';

export default function CryptoPaymentOption({label, value, innerProps, data}) {
  const icon = data.icon;
  const subheading = data.subheading;
  
  return (
    <div className={`${styles['crypto-option']}`} {...innerProps} >
      <span className='flex'>
        <Icon className={`${styles['icon-image']}`} name={icon} />
        <div className={`${styles['crypto-option-text']}`}>
          <span>{label}</span>
          <div className={`${styles['crypto-option-subheading']}`}>{subheading}</div>
        </div>
      </span>
    </div>
  )
}
