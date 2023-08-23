'use client';

import { makeServer } from '../../_mockapi/server';
const environment = process.env.NODE_ENV;

export default function App({ children }: { children: React.ReactNode }) {
  if (environment !== 'production') {
    makeServer();
  }

  return (
    <html>
      <body>{children}</body>
    </html>
  );
}
