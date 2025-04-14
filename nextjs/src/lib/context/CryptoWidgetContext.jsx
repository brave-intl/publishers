"use client";

import { createContext, useState } from "react";

export const CryptoWidgetContext = createContext({});

export function CryptoWidgetProvider({ children }) {
  const [currentChain, setCurrentChain] = useState("");
  const [ratios, setRatios] = useState({});
  const [displayChain, setDisplayChain] = useState("BAT");
  const [currentAmount, setCurrentAmount] = useState(5);
  const [errorTitle, setErrorTitle] = useState(null);
  const [errorMsg, setErrorMsg] = useState(null);
  const [isSuccessView, setIsSuccessView] = useState(false);
  const [isTryBraveModalOpen, setIsTryBraveModalOpen] = useState(false);

  return (
    <CryptoWidgetContext.Provider
      value={{
        currentChain,
        setCurrentChain,
        ratios,
        setRatios,
        displayChain,
        setDisplayChain,
        currentAmount,
        setCurrentAmount,
        errorTitle,
        setErrorTitle,
        errorMsg,
        setErrorMsg,
        isSuccessView,
        setIsSuccessView,
        isTryBraveModalOpen,
        setIsTryBraveModalOpen,
      }}
    >
      {children}
    </CryptoWidgetContext.Provider>
  );
}
