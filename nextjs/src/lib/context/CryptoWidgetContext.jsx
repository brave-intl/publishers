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
  const [isLoading, setIsLoading] = useState(true);
  const [ratios, setRatios] = useState({});
  const [displayChain, SetDisplayChain] = useState('BAT');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isTryBraveModalOpen, setIsTryBraveModalOpen] = useState(false);
  const [customAmount, setCustomAmount] = useState(null);
  const [currentAmount, setCurrentAmount] = useState(5);
  const [errorTitle, setErrorTitle] = useState(null);
  const [errorMsg, setErrorMsg] = useState(null);
  const [displayCrypto, setDisplayCrypto] = useState(false);
  const [isSuccessView, setIsSuccessView] = useState(false);
  const [selectValue, setSelectValue] = useState('')

  return (
    <CryptoWidgetContext.Provider value={{ currentChain, setCurrentChain, isLoading, setIsLoading, ratios, setRatios }}>
      {children}
    </CryptoWidgetContext.Provider>
  )
}