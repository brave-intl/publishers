'use client';
// webpacker does not import the correct version automatically.
// this is necessary for the Solana transfer object to function
import * as buffer from 'buffer';
if (typeof window !== 'undefined') {
  window.Buffer = buffer.Buffer;
}

import { useContext } from 'react';
import { useTranslations } from 'next-intl';
import Web3 from 'web3';
import {
  address,
  appendTransactionMessageInstruction,
  compileTransaction,
  createNoopSigner,
  createSolanaRpc,
  createTransactionMessage,
  getTransactionEncoder,
  lamports,
  pipe,
  setTransactionMessageFeePayer,
  setTransactionMessageLifetimeUsingBlockhash,
} from '@solana/kit';
import { getTransferSolInstruction } from '@solana-program/system';
import {
  findAssociatedTokenPda,
  getCreateAssociatedTokenIdempotentInstruction,
  getTransferInstruction,
  TOKEN_PROGRAM_ADDRESS,
} from '@solana-program/token';

import Button from '@brave/leo/react/button';
import { CryptoWidgetContext } from '@/lib/context/CryptoWidgetContext';
import styles from '@/styles/PublicChannelPage.module.css';
import batAbi from '@/constant/batAbi.json';
import erc20Abi from '@/constant/erc20Abi.json';
import { WalletStandardContext } from './WalletStandardProvider';

const SOLANA_MAINNET_CHAIN = 'solana:mainnet';

export default function CryptoWidgetPaymentButton({
  previewMode,
  addresses,
  cryptoConstants,
}) {
  const t = useTranslations();

  const ethBatAddress = cryptoConstants.eth_bat_address;
  const solanaBatAddress = cryptoConstants.solana_bat_address;
  const solanaMainUrls = cryptoConstants.solana_main_urls;
  const rpcHost = solanaMainUrls.filter((url) =>
    url.toLowerCase().includes(window.location.origin.toLowerCase()),
  )[0];
  const ethUsdcAddress = cryptoConstants.eth_usdc_address;
  const solUsdcAddress = cryptoConstants.solana_usdc_address;

  const {
    currentChain,
    currentAmount,
    setIsSuccessView,
    setErrorMsg,
    setErrorTitle,
    setIsTryBraveModalOpen,
  } = useContext(CryptoWidgetContext);

  const {
    wallets: solanaWallets,
    wallet: connectedWallet,
    account: connectedAccount,
    connect: connectWallet,
    disconnect: disconnectWallet,
  } = useContext(WalletStandardContext);

  async function sendPayment() {
    clearError();

    const paymentFunctions = {
      ETH: sendEthPayment,
      SOL: sendSolPayment,
      BAT: sendEthBatPayment,
      splBAT: sendSolBatPayment,
      USDC: sendEthUsdcPayment,
      'USDC-SPL': sendSolUsdcPayment,
    };

    paymentFunctions[currentChain]();
  }

  function setGenericError() {
    setErrorTitle(t('publicChannelPage.ErrorTitle'));
    setErrorMsg(t('publicChannelPage.ErrorMsg'));
  }

  function setError(titleId, msgId) {
    setErrorTitle(t(titleId));
    setErrorMsg(t(msgId));
  }

  function clearError() {
    setErrorTitle(null);
    setErrorMsg(null);
  }

  async function sendEthPayment() {
    if (typeof window !== 'undefined' && window.ethereum) {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });
      const address = accounts[0];
      if (!address) {
        setGenericError();
        return;
      }

      // While most guides to converting eth to wei multiply the value by 10e18, In javascript e counts
      // as the 10 and *10e18 results in a value that is an order of mangitude too high.
      const value = Web3.utils.toHex(
        Web3.utils.toBigInt(Math.round(currentAmount * 10e17)),
      );

      const params = [
        {
          from: address,
          to: addresses.ETH,
          value: value,
        },
      ];

      window.ethereum
        .request({
          method: 'eth_sendTransaction',
          params,
        })
        .then((result) => {
          setIsSuccessView(true);
        })
        .catch((error) => {
          setGenericError();
        });
    } else {
      setIsTryBraveModalOpen(true);
      setError('publicChannelPage.noEthTitle', 'publicChannelPage.noEthMsg');
      return;
    }
  }

  async function sendEthTokenPayment(contractAddress, amount, abi) {
    if (typeof window !== 'undefined' && window.ethereum) {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });
      const address = accounts[0];

      if (!address) {
        setGenericError();
        return;
      }

      try {
        const web3 = new Web3(window.ethereum);
        const contract = new web3.eth.Contract(abi, contractAddress);
        const encodedAbi = await contract.methods
          .transfer(addresses.ETH, amount)
          .encodeABI();
        const gasPrice = await web3.eth.getGasPrice();

        const transaction = {
          from: address,
          to: contractAddress,
          value: '0', // note that value is a string
          data: encodedAbi,
          gasPrice,
        };
        const gasEstimate = await web3.eth.estimateGas(transaction);
        const results = await web3.eth.sendTransaction({
          ...transaction,
          gas: gasEstimate + Web3.utils.toBigInt(450000),
        });

        if (results.status > 0) {
          setIsSuccessView(true);
        }
      } catch (e) {
        console.log(e);
        setGenericError();
        return;
      }
    } else {
      setIsTryBraveModalOpen(true);
      setError('publicChannelPage.noEthTitle', 'publicChannelPage.noEthMsg');
      return;
    }
  }

  async function sendEthBatPayment() {
    const amount = Web3.utils.toBigInt(Math.round(currentAmount * 10e17));
    await sendEthTokenPayment(ethBatAddress, amount, batAbi);
  }

  async function sendEthUsdcPayment() {
    // USDC token needs 6 decimal places, not 18
    const amount = Web3.utils.toBigInt(Math.round(currentAmount * 10e5));
    await sendEthTokenPayment(ethUsdcAddress, amount, erc20Abi);
  }

  async function sendSolPayment() {
    if (solanaWallets.length === 0) {
      setIsTryBraveModalOpen(true);
      setError('publicChannelPage.noSolTitle', 'publicChannelPage.noSolMsg');
      return;
    } else {
      const provider =
        connectedWallet && connectedAccount
          ? { wallet: connectedWallet, account: connectedAccount }
          : await connectWallet();
      if (provider?.account?.address) {
        const feePayer = address(provider.account.address);
        const feePayerSigner = createNoopSigner(feePayer);
        const rpc = createSolanaRpc(`https://solana-mainnet.g.alchemy.com/v2/alch_t3JohD-tBeSbepLVP3cKF`);
        const transferAmount = lamports(
          BigInt(Math.round(currentAmount * 1_000_000_000)),
        );
        const { value: latestBlockhash } = await rpc
          .getLatestBlockhash({ commitment: 'confirmed' })
          .send();

        const transactionMessage = pipe(
          createTransactionMessage({ version: 0 }),
          (tx) => setTransactionMessageFeePayer(feePayer, tx),
          (tx) => setTransactionMessageLifetimeUsingBlockhash(latestBlockhash, tx),
          (tx) =>
            appendTransactionMessageInstruction(
              getTransferSolInstruction({
                source: feePayerSigner,
                destination: address(addresses.SOL),
                amount: transferAmount,
              }),
              tx,
            ),
        );

        try {
          const wireBytes = new Uint8Array(
            getTransactionEncoder().encode(compileTransaction(transactionMessage)),
          );
          const results = await provider.wallet.features[
            'solana:signAndSendTransaction'
          ].signAndSendTransaction({
            account: provider.account,
            transaction: wireBytes,
            chain: SOLANA_MAINNET_CHAIN,
          });
          if (results?.[0]?.signature) {
            disconnectWallet();
            setIsSuccessView(true);
          }
        } catch (e) {
          setGenericError();
          disconnectWallet();
        }
      } else {
        setGenericError();
        return;
      }
    }
  }

  async function sendSolTokenPayment(contractAddress, decimal) {
    if (solanaWallets.length === 0) {
      setIsTryBraveModalOpen(true);
      setError('publicChannelPage.noSolTitle', 'publicChannelPage.noSolMsg');
      return;
    } else {
      const provider =
        connectedWallet && connectedAccount
          ? { wallet: connectedWallet, account: connectedAccount }
          : await connectWallet();
      if (provider?.account?.address) {
        try {
          // multiply the number of tokens to the power of the decimals in the token program
          const amount = BigInt(
            Math.round(currentAmount * Math.pow(10, decimal)),
          );
          const sourceOwner = address(provider.account.address);
          const sourceOwnerSigner = createNoopSigner(sourceOwner);
          const destinationOwner = address(addresses.SOL);
          const mint = address(contractAddress);
          const rpc = createSolanaRpc(`${rpcHost}/rpc`);

          // Derive sender and receiver associated token accounts (ATAs)
          const [senderAta] = await findAssociatedTokenPda({
            mint,
            owner: sourceOwner,
            tokenProgram: TOKEN_PROGRAM_ADDRESS,
          });
          const [destinationAta] = await findAssociatedTokenPda({
            mint,
            owner: destinationOwner,
            tokenProgram: TOKEN_PROGRAM_ADDRESS,
          });

          // Verify the sender actually holds this token before building the tx
          const { value: senderAccountInfo } = await rpc
            .getAccountInfo(senderAta, { commitment: 'confirmed' })
            .send();
          if (!senderAccountInfo) {
            setError(
              'publicChannelPage.ErrorTitle',
              'publicChannelPage.insufficientBalance',
            );
            disconnectWallet();
            return;
          }

          const { value: latestBlockhash } = await rpc
            .getLatestBlockhash({ commitment: 'confirmed' })
            .send();

          // Idempotent create — no-op if the receiver ATA already exists
          const createDestinationInstruction =
            getCreateAssociatedTokenIdempotentInstruction({
              payer: sourceOwnerSigner,
              ata: destinationAta,
              owner: destinationOwner,
              mint,
            });
          const transferInstruction = getTransferInstruction({
            source: senderAta,
            destination: destinationAta,
            authority: sourceOwnerSigner,
            amount,
          });

          const transactionMessage = pipe(
            createTransactionMessage({ version: 0 }),
            (tx) => setTransactionMessageFeePayer(sourceOwner, tx),
            (tx) =>
              setTransactionMessageLifetimeUsingBlockhash(latestBlockhash, tx),
            (tx) =>
              appendTransactionMessageInstruction(
                createDestinationInstruction,
                tx,
              ),
            (tx) => appendTransactionMessageInstruction(transferInstruction, tx),
          );
          const wireBytes = new Uint8Array(
            getTransactionEncoder().encode(
              compileTransaction(transactionMessage),
            ),
          );

          const results = await provider.wallet.features[
            'solana:signAndSendTransaction'
          ].signAndSendTransaction({
            account: provider.account,
            transaction: wireBytes,
            chain: SOLANA_MAINNET_CHAIN,
          });

          if (results?.[0]?.signature) {
            disconnectWallet();
            setIsSuccessView(true);
          }
        } catch (e) {
          setGenericError();
          disconnectWallet();
        }
      } else {
        setGenericError();
        return;
      }
    }
  }

  async function sendSolBatPayment() {
    await sendSolTokenPayment(solanaBatAddress, 8);
  }

  async function sendSolUsdcPayment() {
    await sendSolTokenPayment(solUsdcAddress, 6);
  }

  return (
    <Button
      onClick={(event) => {
        event.preventDefault();
        sendPayment();
      }}
      isDisabled={currentAmount <= 0 || previewMode}
      className={`mb-3 ${styles['send-button']}`}
    >
      {t('publicChannelPage.send')}
    </Button>
  );
}
