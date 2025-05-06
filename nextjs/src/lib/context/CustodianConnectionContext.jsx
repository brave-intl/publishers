'use client';

import { createContext, useState } from 'react';

export const CustodianConnectionContext = createContext({
  upholdConnection: {},
  setUpholdConnection: ({}) => {},
  geminiConnection: {},
  setGeminiConnection: ({}) => {},
  bitflyerConnection: {},
  setBitflyerConnection: ({}) => {},
  allowedRegions: {},
  setAllowedRegions: ({}) => {}
});

export default function CustodianConnectionProvider({
  children,
}) {

  const [upholdConnection, setUpholdConnection] = useState({});
  const [geminiConnection, setGeminiConnection] = useState({});
  const [bitflyerConnection, setBitflyerConnection] = useState({});
  const [allowedRegions, setAllowedRegions] = useState({})

  return (
    <CustodianConnectionContext.Provider
      value={{
        upholdConnection,
        setUpholdConnection,
        geminiConnection,
        setGeminiConnection,
        bitflyerConnection,
        setBitflyerConnection,
        allowedRegions,
        setAllowedRegions
      }}
    >
      {children}
    </CustodianConnectionContext.Provider>
  );
}
