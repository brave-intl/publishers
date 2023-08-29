'use client';

import clsx from 'clsx';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { useContext, useRef, useState } from 'react';

import UserContext from '@/lib/context/UserContext';
import useClickAway from '@/lib/hooks/useClickAway';

import Chevron from '~/icons/arrow-small-up.svg';
import Unlock from '~/icons/lock-plain.svg';
import UserAvatar from '~/images/user_avatar.svg';

const NavDropdown = () => {
  const { user } = useContext(UserContext);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const clickRef = useRef();
  const t = useTranslations('NavDropdown');

  const handleOnClick = () => {
    setIsDropdownOpen(!isDropdownOpen);
  };

  useClickAway(clickRef, () => {
    setIsDropdownOpen(false);
  });

  const Avatar = () => (
    <div className='border-primary m-0.5 flex h-[40px] w-[40px] justify-center rounded-full'>
      <UserAvatar className='h-[36px] w-[36px] rounded-full' />
    </div>
  );

  return (
    <>
      <div
        className='flex cursor-pointer items-center'
        onClick={handleOnClick}
        ref={clickRef}
      >
        <Avatar />
        <Unlock className='my-0.5 mb-1 mt-1 block h-[18px] w-[18px]' />
        <Chevron
          className={clsx('m-0.5 h-4 w-4 duration-300', {
            'rotate-180': !isDropdownOpen,
          })}
        />
        {isDropdownOpen && (
          <div className='rounded-sm shadow absolute right-2 top-full z-10 min-w-[250px] bg-white'>
            <div className='flex flex-col items-center p-2'>
              <Avatar />
              <h3>{user.name}</h3>
              <div className='text-gray-40'>{user.email}</div>
            </div>
            <ul className='flex flex-col'>
              {['security', 'settings', 'log_out', 'help', 'faqs'].map(
                (title) => (
                  <li
                    key={title}
                    className='border-t border-gray-20 p-2 text-center'
                  >
                    <Link href={`/publishers/${title}`}>{t(title)}</Link>
                  </li>
                ),
              )}
            </ul>
          </div>
        )}
      </div>
    </>
  );
};

export default NavDropdown;
