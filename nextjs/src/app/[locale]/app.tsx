'use client';

import { useEffect, useState } from 'react';

// import { makeServer } from '../../_mockapi/server';
const environment = process.env.NODE_ENV;

export default function App({ children }: { children: React.ReactNode }) {
  const [mockServer, setMockServer] = useState(false);

  useEffect(() => {
    // set theme
    if (environment === 'development') {
      const theme = localStorage.getItem('theme');
      if (theme) document.body.setAttribute('data-theme', theme);
    } else {
      document.body.setAttribute('data-theme', 'light');
    }
  }, []);

  if (environment !== 'production' && !mockServer) {
    // makeServer();
    setMockServer(true);
  }

  return <>{children}</>;
}
