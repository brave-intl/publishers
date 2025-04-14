"use client";
// webpacker does not import the correct version automatically.
// this is necessary for the Solana transfer object to function
import * as buffer from "buffer";
if (typeof window !== "undefined") {
  window.Buffer = buffer.Buffer;
}

import { useContext } from "react";
import { useTranslations } from "next-intl";
import Web3 from "web3";
import {
  Connection,
  SystemProgram,
  LAMPORTS_PER_SOL,
  Transaction,
  PublicKey,
} from "@solana/web3.js";
import {
  getAssociatedTokenAddress,
  createAssociatedTokenAccountInstruction,
  createTransferInstruction,
} from "@solana/spl-token";

import Button from "@brave/leo/react/button";
import { CryptoWidgetContext } from "@/lib/context/CryptoWidgetContext";
import styles from "@/styles/PublicChannelPage.module.css";
import batAbi from "@/constant/batAbi.json";
import erc20Abi from "@/constant/erc20Abi.json";

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
    url.toLowerCase().includes(window.location.host.toLowerCase()),
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

  async function sendPayment() {
  clearError();

  const paymentFunctions = {
    "ETH": sendEthPayment,
    "SOL": sendSolPayment,
    "BAT": sendEthBatPayment,
    "splBAT": sendSolBatPayment,
    "USDC": sendEthUsdcPayment,
    "USDC-SPL": sendSolUsdcPayment,
  };

  paymentFunctions[currentChain]();
}

  function setGenericError() {
    setErrorTitle(t("publicChannelPage.ErrorTitle"));
    setErrorMsg(t("publicChannelPage.ErrorMsg"));
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
    if (typeof window !== "undefined" && window.ethereum) {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
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
          method: "eth_sendTransaction",
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
      setError("publicChannelPage.noEthTitle", "publicChannelPage.noEthMsg");
      return;
    }
  }

  async function sendEthTokenPayment(contractAddress, amount, abi) {
    if (typeof window !== "undefined" && window.ethereum) {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
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
          value: "0", // note that value is a string
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
        setGenericError();
        return;
      }
    } else {
      setIsTryBraveModalOpen(true);
      setError("publicChannelPage.noEthTitle", "publicChannelPage.noEthMsg");
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
    if (typeof window !== "undefined" && !window.solana) {
      setIsTryBraveModalOpen(true);
      setError("publicChannelPage.noSolTitle", "publicChannelPage.noSolMsg");
      return;
    } else {
      const provider = await window.solana.connect();
      if (provider.publicKey) {
        const pub_key = provider.publicKey;
        const connection = new Connection(`${rpcHost}/rpc`);
        const amount = Math.round(currentAmount * LAMPORTS_PER_SOL);

        const transaction = new Transaction().add(
          SystemProgram.transfer({
            fromPubkey: pub_key,
            toPubkey: addresses.SOL,
            lamports: amount,
          }),
        );
        transaction.feePayer = pub_key;
        const blockhashObj = await connection.getLatestBlockhash("confirmed");
        transaction.recentBlockhash = await blockhashObj.blockhash;

        try {
          const result =
            await window.solana.signAndSendTransaction(transaction);
          if (result.signature) {
            window.solana.disconnect();
            setIsSuccessView(true);
          }
        } catch (e) {
          setGenericError();
          window.solana.disconnect();
        }
      } else {
        setGenericError();
        return;
      }
    }
  }

  async function sendSolTokenPayment(contractAddress, decimal) {
    if (typeof window !== "undefined" && !window.solana) {
      setIsTryBraveModalOpen(true);
      setError("publicChannelPage.noSolTitle", "publicChannelPage.noSolMsg");
      return;
    } else {
      const provider = await window.solana.connect();

      if (provider.publicKey) {
        try {
          // This is the account address of the user who is sending bat
          const sourceAccountOwner = provider.publicKey;
          // multiply the number of bat tokens to the power of the decimals in the token program
          const amount = Math.round(currentAmount * Math.pow(10, decimal));
          // this is the account address that will receive bat
          const destinationAccountOwner = new PublicKey(addresses.SOL);
          const connection = new Connection(`${rpcHost}/rpc`);
          const contract = new PublicKey(contractAddress);
          // Check to see if the sender has an associated token account
          const senderAccount = await connection.getParsedTokenAccountsByOwner(
            sourceAccountOwner,
            {
              mint: contract,
            },
          );

          if (senderAccount.value.length > 0) {
            const senderTokenAddress = senderAccount.value[0].pubkey;
            // get receiver associated token account

            const destinationAccount =
              await connection.getParsedTokenAccountsByOwner(
                destinationAccountOwner,
                {
                  mint: contract,
                },
              );
            // Does the receiver token account already exist?
            const hasDestinationAccount = destinationAccount.value.length > 0;
            // Get the receiver token address, whether it exists or not
            const destinationTokenAddress = hasDestinationAccount
              ? destinationAccount.value[0].pubkey
              : await getAssociatedTokenAddress(
                  contract,
                  destinationAccountOwner,
                );

            const tx = new Transaction();
            // if the token accout has not been created, add an instruction to create it
            if (!hasDestinationAccount) {
              tx.add(
                createAssociatedTokenAccountInstruction(
                  sourceAccountOwner,
                  destinationTokenAddress,
                  destinationAccountOwner,
                  contract,
                ),
              );
            }
            // Add the instruction to transfer the tokens
            tx.add(
              createTransferInstruction(
                senderTokenAddress,
                destinationTokenAddress,
                sourceAccountOwner,
                amount,
              ),
            );

            tx.feePayer = sourceAccountOwner;
            const latestBlockHash =
              await connection.getLatestBlockhash("confirmed");
            tx.recentBlockhash = latestBlockHash.blockhash;

            const signature = await window.solana.signAndSendTransaction(tx);

            if (signature.signature) {
              window.solana.disconnect();
              setIsSuccessView(true);
            }
          } else {
            setError(
              "publicChannelPage.ErrorTitle",
              "publicChannelPage.insufficientBalance",
            );
            window.solana.disconnect();
            return;
          }
        } catch (e) {
          setGenericError();
          window.solana.disconnect();
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
      className={`mb-3 ${styles["send-button"]}`}
    >
      {t("publicChannelPage.send")}
    </Button>
  );
}
