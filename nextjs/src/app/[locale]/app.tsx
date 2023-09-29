'use client';

import { useState } from 'react';

// import { makeServer } from '../../_mockapi/server';
const environment = process.env.NODE_ENV;

export default function App({ children }: { children: React.ReactNode }) {
  const [mockServer, setMockServer] = useState(false);

  if (environment !== 'production' && !mockServer) {
    // makeServer();
    setMockServer(true);
  }

  return <>{children}</>;
}
