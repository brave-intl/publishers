'use client';

import { createContext, useState } from 'react';

export const CustodianConnectionContext = createContext({
  upholdConnection: {},
  setUpholdConnection: ({}) => {},
  bitflyerConnection: {},
  setBitflyerConnection: ({}) => {},
  allowedRegions: {},
  setAllowedRegions: ({}) => {},
});

export default function CustodianConnectionProvider({ children }) {
  const [upholdConnection, setUpholdConnection] = useState({});
  const [bitflyerConnection, setBitflyerConnection] = useState({});
  const [allowedRegions, setAllowedRegions] = useState({});

  return (
    <CustodianConnectionContext.Provider
      value={{
        upholdConnection,
        setUpholdConnection,
        bitflyerConnection,
        setBitflyerConnection,
        allowedRegions,
        setAllowedRegions,
      }}
    >
      {children}
    </CustodianConnectionContext.Provider>
  );
}
