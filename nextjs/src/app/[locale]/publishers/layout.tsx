import Image from 'next/image';

import UserProvider from '@/components/UserProvider';

import NavDropdown from './NavDropdown';

import profilePic from '~/images/brave_creators_logo.png';

export default function NavigationLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <UserProvider>
      <div className='relative flex items-center justify-between bg-container px-2 transition-colors'>
        <Image
          src={profilePic}
          alt='Brave Creators Logo'
          height={80}
          priority={true}
        />
        <NavDropdown />
      </div>
      {children}
    </UserProvider>
  );
}
