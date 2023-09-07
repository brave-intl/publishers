'use client';

import Image from 'next/image';
import { createContext, useEffect, useState } from 'react';

import styles from './styles.module.css';

import { UserType } from '@/lib/propTypes';

import NavDropdown from './NavDropdown';

import profilePic from '~/images/brave_creators_logo.png';

const UserContext = createContext({});

export default function NavigationLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [userData, setUserData] = useState<Partial<UserType>>({});

  async function getUser() {
    try {
      const res = await fetch('https://localhost:3001/api/v1/user/me');
      const data = await res.json();
      setUserData(data);
    } catch (err) {
      return err;
    }
  }

  useEffect(() => {
    getUser();
  }, []);

  return (
    <UserContext.Provider value={userData}>
      <div className={styles.navbar}>
        <Image src={profilePic} alt='Brave Creators Logo' height={80} />
        <NavDropdown userEmail={userData.email} userName={userData.name} />
      </div>
      {children}
    </UserContext.Provider>
  );
}
