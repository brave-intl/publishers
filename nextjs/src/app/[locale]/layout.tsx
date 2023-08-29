import { Metadata } from 'next';
import { Poppins } from 'next/font/google';
// import { cookies, headers } from 'next/headers';
import { notFound } from 'next/navigation';
import { NextIntlClientProvider } from 'next-intl';
import * as React from 'react';

import '@/styles/globals.css';

import { siteConfig } from '@/constant/config';

import App from './app';

const poppins = Poppins({
  weight: ['400', '500', '600', '700'],
  style: ['normal', 'italic'],
  variable: '--font-poppins',
  subsets: ['latin'],
});

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

// async function getUser() {
//   try {
//     console.log(headers());
//     console.log(cookies());

//     const pubCookieSession = cookies().get('_publishers_session')?.value ?? '';

//     console.log(pubCookieSession);
//     const options = {
//       headers: {
//         'Content-Type': 'application/json',
//         Cookie: `_publishers_session=${pubCookieSession}`,
//       },
//     };
//     const res = await fetch(
//       'https://127.0.0.1:3000/api/nextv1/publishers/me',
//       options,
//     );

//     const data = await res.json();
//     console.log(data);
//     // setUserData(data);
//   } catch (err) {
//     return err;
//   }
// }

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
    <html className={poppins.variable}>
      <body>
        <NextIntlClientProvider locale={locale} messages={messages}>
          <App>{children}</App>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
