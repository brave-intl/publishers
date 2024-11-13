import { Metadata } from 'next';
import { getTranslations } from 'next-intl/server';

export function generateStaticParams() {
  return [{ locale: 'en' }, { locale: 'ja' }];
}

// Look at @/constant/config to change them
export async function generateMetadata({ params: { locale }}) {
  const t = await getTranslations({ locale, namespace: 'metadata'});
  return {
    title: t('dashboard'),
    description: t("description"),
    icons: {
      icon: '/favicon/favicon.ico',
    },
    manifest: `/favicon/site.webmanifest`,
  };
}

export default async function RootLayout({ children }) {
  return <>{children}</>;
}
