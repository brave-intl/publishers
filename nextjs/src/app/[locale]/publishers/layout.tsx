import Image from 'next/image';

import UserProvider from '@/components/UserProvider';
import { unstable_setRequestLocale } from 'next-intl/server';

import NavDropdown from './NavDropdown';

export default function NavigationLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: { locale: string };
}) {
  unstable_setRequestLocale(params.locale);
  return (
    <UserProvider>
      <div className='bg-container relative flex items-center justify-between px-2 transition-colors'>
        <Image
          src='/images/brave_creators_logo.png'
          alt='Brave Creators Logo'
          height={80}
          width={250}
          priority={true}
        />
        <NavDropdown />
      </div>
      {children}
    </UserProvider>
  );
}
