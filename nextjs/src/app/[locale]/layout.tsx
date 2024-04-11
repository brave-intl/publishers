import { Metadata } from 'next';
// import { cookies, headers } from 'next/headers';
import { notFound } from 'next/navigation';
import { NextIntlClientProvider } from 'next-intl';
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
export const metadata: Metadata = {
  title: {
    default: siteConfig.title,
    template: `%s | ${siteConfig.title}`,
  },
  description: siteConfig.description,
  robots: { index: true, follow: true },
  icons: {
    icon: '/favicon/favicon.ico',
  },
  manifest: `/favicon/site.webmanifest`,
  openGraph: {
    url: siteConfig.url,
    title: siteConfig.title,
    description: siteConfig.description,
    siteName: siteConfig.title,
    type: 'website',
    locale: 'en_US',
  },
  twitter: {
    card: 'summary_large_image',
    title: siteConfig.title,
    description: siteConfig.description,
  },
};

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
