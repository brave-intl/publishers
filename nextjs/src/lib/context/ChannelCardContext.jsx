'use client';

import { createContext, useState } from 'react';

export const ChannelCardContext = createContext({
  hasCustodian: false,
  hasCrypto: false,
  setHasCustodian: () => {},
  setHasCrypto: () => {},
});

export default function ChannelCardProvider({
  children,
}) {

  const [hasCrypto, setHasCrypto] = useState(false);
  const [hasCustodian, setHasCustodian] = useState(false);

  return (
    <ChannelCardContext.Provider
      value={{
        hasCustodian,
        hasCrypto,
        setHasCustodian,
        setHasCrypto,
      }}
    >
      {children}
    </ChannelCardContext.Provider>
  );
}
