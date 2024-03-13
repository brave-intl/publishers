import Image from 'next/image';

import UserProvider from '@/components/UserProvider';

import NavDropdown from './NavDropdown';

export default function NavigationLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <UserProvider>
      <div className='bg-container relative flex items-center justify-between px-2 transition-colors'>
        <img
          src='/images/brave_creators_logo.png'
          alt='Brave Creators Logo'
          height={80}
        />
        <NavDropdown />
      </div>
      {children}
    </UserProvider>
  );
}
