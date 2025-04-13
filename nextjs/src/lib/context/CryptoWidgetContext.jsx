// import React, { createContext } from 'react';

// const CryptoWidgetContext = createContext({

// });

// export const CryptoWidgetProvider = ({ children }) => {
//     return (
//     <WalletContext.Provider>
//       {children}
//     </WalletContext.Provider>
//   );
// };


// export default CryptoWidgetContext;


'use client';
import { createContext, useState } from 'react';

export const CryptoWidgetContext = createContext({});

export function CryptoWidgetProvider({ children }) {
  const [currentChain, setCurrentChain] = useState('BAT');
  const [ratios, setRatios] = useState({});
  const [displayChain, setDisplayChain] = useState('BAT');
  const [currentAmount, setCurrentAmount] = useState(5);
  const [errorTitle, setErrorTitle] = useState(null);
  const [errorMsg, setErrorMsg] = useState(null);

  return (
    <CryptoWidgetContext.Provider value={{ currentChain, setCurrentChain, ratios, setRatios, displayChain, setDisplayChain, currentAmount, setCurrentAmount }}>
      {children}
    </CryptoWidgetContext.Provider>
  )
}