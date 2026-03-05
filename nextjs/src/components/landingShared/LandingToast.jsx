'use client';

import Icon from '@brave/leo/react/icon';
import styles from '@/styles/LandingPages.module.css';

export default function LandingToast({ notification, closeNotification }) {
  return (
    <div
      className={` ${styles['notification-layer']} ${notification.show ? 'bottom-0' : 'hidden'}`}
    >
      <div className={`${styles['notification-wrapper']}`}>
        <Icon name='info-outline' className='mr-[12px] text-[#E32444]' />
        <span className='text-[16px] leading-[1.25]'>{notification.text}</span>
        <button onClick={closeNotification} className='ml-[12px]'>
          <Icon name='close' />
        </button>
      </div>
    </div>
  );
}
