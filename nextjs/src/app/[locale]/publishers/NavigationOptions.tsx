'use client';

import NavigationItem from '@brave/leo/react/navigationItem';
import NavigationMenu from '@brave/leo/react/navigationMenu';
import { useTranslations } from 'next-intl';
import { useContext, useEffect, useState } from 'react';
import UserContext from '@/lib/context/UserContext';

export default function NavigationOptions() {
  const t = useTranslations();
  const [route, setRoute] = useState('');
  const { user } = useContext(UserContext);

  useEffect(() => {
    setRoute(window.location.pathname);
  }, []);

  return (
    <NavigationMenu>
      <NavigationItem
        icon='browser-home'
        href='/publishers/home'
        isCurrent={route.includes('/publishers/home')}
      >
        {t('shared.dashboard')}
      </NavigationItem>
      <NavigationItem
        icon='window-settings'
        href={`/publishers/${user.id}/site_banners/new`}
        isCurrent={route.includes(`/publishers/${user.id}/site_banners/new`)}
      >
        {t('NavDropdown.contribution_banners')}
      </NavigationItem>
      <NavigationItem
        icon='lock'
        href='/publishers/security'
        isCurrent={route.includes('/publishers/security')}
      >
        {t('NavDropdown.security')}
      </NavigationItem>
      <NavigationItem
        icon='settings'
        href='/publishers/settings'
        isCurrent={route.includes('/publishers/settings')}
      >
        {t('NavDropdown.settings')}
      </NavigationItem>
    </NavigationMenu>
  );
}
