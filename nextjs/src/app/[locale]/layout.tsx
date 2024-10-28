import { Metadata } from 'next';
// import { cookies, headers } from 'next/headers';
import { notFound } from 'next/navigation';
import { NextIntlClientProvider } from 'next-intl';
import { unstable_setRequestLocale, getTranslations } from 'next-intl/server';
import * as React from 'react';
import '@fontsource/poppins';
import '@fontsource/inter';
import '@fontsource/dm-mono';

import '@/styles/globals.css';

import { siteConfig } from '@/constant/config';

import App from './app';

export function generateStaticParams() {
  return [{ locale: 'en' }, { locale: 'ja' }];
}

// Look at @/constant/config to change them
export async function generateMetadata({ params: { locale }}) {
  const t = await getTranslations({ locale, namespace: 'metadata'});
 
  return {
    title: {
      default: t("title"),
      template: `${t("title")} - %s`,
    },
    description: t("description"),
    robots: { index: true, follow: true },
    icons: {
      icon: '/favicon/favicon.ico',
    },
    manifest: `/favicon/site.webmanifest`,
    openGraph: {
      url: siteConfig.url,
      title: t("title"),
      description: t("description"),
      siteName: t("title"),
      type: 'website',
      locale: 'en_US',
    },
    twitter: {
      card: 'summary_large_image',
      title: t("title"),
      description: t("description"),
    },
  };
}

export default async function RootLayout({
  children,
  params: { locale },
}: {
  children: React.ReactNode;
  params: { locale: string };
}) {
  // load messages based on locale
  let messages;
  try {
    messages = (await import(`../../messages/${locale}.json`)).default;
  } catch (error) {
    notFound();
  }

  unstable_setRequestLocale(locale);

  return (
    <html>
      <body>
        <NextIntlClientProvider locale={locale} messages={messages}>
          <App>{children}</App>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
