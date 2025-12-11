'use client';

import { useEffect } from 'react';
import Nav from '@/components/landingShared/Nav';
import LandingHome from '@/components/landingShared/LandingHome';
import Spotlight from '@/components/landingShared/Spotlight';
import Summary from '@/components/landingShared/Summary';
import Signoff from '@/components/landingShared/Signoff';
import Footer from '@/components/landingShared/Footer';
import styles from '@/styles/LandingPages.module.css';

export default function LandingPage() {
  useEffect(() => {
    document.title = 'Log In - Brave Creators';
  }, []);

  return (
    <div className={`${styles['landing-wrapper']}`}>
      <Nav />
      <LandingHome />
      <Spotlight />
      <Summary />
      <Signoff />
      <Footer />
    </div>
  );
}
