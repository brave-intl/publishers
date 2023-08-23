'use client';

import clsx from 'clsx';
import { useTranslations } from 'next-intl';
import { FC } from 'react';
import { useState } from 'react';

import styles from './styles.module.css';

// import useClickAway from '@/lib/hooks/useClickAway';

import Chevron from '~/icons/chevron.svg';
import Unlock from '~/icons/unlock.svg';
import UserAvatar from '~/images/user_avatar.svg';

type Props = {
  userEmail: string;
  userName: string;
};

const NavDropdown: FC<Props> = ({ userEmail, userName }) => {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  // const clickRef = useRef();
  const t = useTranslations('NavDropdown');

  const handleOnClick = () => {
    setIsDropdownOpen(!isDropdownOpen);
  };

  // useClickAway(clickRef, () => {
  //   setIsDropdownOpen(false);
  // });

  return (
    <>
      <div
        className={styles.dropdownWrap}
        onClick={handleOnClick}
        // ref={clickRef}
      >
        <div className={styles.avatar}>
          <UserAvatar />
        </div>
        <Unlock className={styles.lock} />
        <Chevron
          className={clsx(styles.chevron, {
            [styles.active]: isDropdownOpen,
          })}
        />
        {isDropdownOpen && (
          <div className={styles.dropdown}>
            <div className={styles.userInfo}>
              <div className={styles.avatar}>
                <UserAvatar />
              </div>
              <div className={styles.userName}>{userName}</div>
              <div className={styles.userEmail}>{userEmail}</div>
            </div>
            <ul className={styles.userLinks}>
              <li>
                <a href=''>{t('security')}</a>
              </li>
              <li>
                <a href=''>{t('log_out')}</a>
              </li>
              <li>
                <a href=''>{t('help')}</a>
              </li>
              <li>
                <a href=''>{t('faqs')}</a>
              </li>
            </ul>
          </div>
        )}
      </div>
    </>
  );
};

export default NavDropdown;
