'use client';

import {
  createContext,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from 'react';
import { getWallets } from '@wallet-standard/app';

const STANDARD_CONNECT = 'standard:connect';
const STANDARD_DISCONNECT = 'standard:disconnect';
const SOLANA_SIGN_AND_SEND = 'solana:signAndSendTransaction';

function isSolanaWallet(wallet) {
  return (
    wallet?.features &&
    STANDARD_CONNECT in wallet.features &&
    SOLANA_SIGN_AND_SEND in wallet.features
  );
}

export const WalletStandardContext = createContext({
  wallets: [],
  wallet: null,
  account: null,
  connect: async () => null,
  disconnect: async () => {},
});

export default function WalletStandardProvider({ children }) {
  const [wallets, setWallets] = useState([]);
  const [wallet, setWallet] = useState(null);
  const [account, setAccount] = useState(null);

  useEffect(() => {
    const api = getWallets();
    setWallets(api.get().filter(isSolanaWallet));

    const offRegister = api.on('register', (...registered) => {
      const solanaWallets = registered.filter(isSolanaWallet);
      if (solanaWallets.length === 0) return;
      setWallets((prev) => [...prev, ...solanaWallets]);
    });
    const offUnregister = api.on('unregister', (...unregistered) => {
      setWallets((prev) => prev.filter((w) => !unregistered.includes(w)));
      setWallet((current) => (unregistered.includes(current) ? null : current));
    });

    return () => {
      offRegister();
      offUnregister();
    };
  }, []);

  const connect = useCallback(
    async (target) => {
      const chosen = target ?? wallet ?? wallets[0];
      if (!chosen) return null;

      const { accounts } = await chosen.features[STANDARD_CONNECT].connect();
      const first = accounts?.[0] ?? chosen.accounts?.[0] ?? null;
      if (!first) return null;

      setWallet(chosen);
      setAccount(first);
      return { wallet: chosen, account: first };
    },
    [wallet, wallets],
  );

  const disconnect = useCallback(async () => {
    if (wallet && STANDARD_DISCONNECT in wallet.features) {
      try {
        await wallet.features[STANDARD_DISCONNECT].disconnect();
      } catch {
        // ignore — some wallets throw on disconnect if already gone
      }
    }
    setWallet(null);
    setAccount(null);
  }, [wallet]);

  const value = useMemo(
    () => ({ wallets, wallet, account, connect, disconnect }),
    [wallets, wallet, account, connect, disconnect],
  );

  return (
    <WalletStandardContext.Provider value={value}>
      {children}
    </WalletStandardContext.Provider>
  );
}
