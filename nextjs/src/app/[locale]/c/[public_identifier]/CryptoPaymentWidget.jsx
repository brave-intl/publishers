'use client';
// webpacker does not import the correct version automatically.
// this is necessary for the Solana transfer object to function
import * as buffer from "buffer";
if (typeof window !== 'undefined') {
  window.Buffer = buffer.Buffer;
}
// one of the libraries that the QR code modal depends on references the dom, so
// it needs to be loaded with ssr set to false
import dynamic from 'next/dynamic';
const QRCodeModal = dynamic(() => import('./QRCodeModal'), {
  ssr: false
});
import { useEffect, useState } from 'react';
import { useTranslations } from 'next-intl';
import Web3 from "web3";
import {
  Connection,
  Keypair,
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

import Icon from '@brave/leo/react/icon';
import Select, { components } from 'react-select';
import Dialog from '@brave/leo/react/dialog';
import Button from '@brave/leo/react/button';
import TryBraveModal from "./TryBraveModal";
import CryptoPaymentOption from "./CryptoPaymentOption";
import SuccessWidget from "./SuccessWidget";
import { apiRequest } from '@/lib/api';
import styles from '@/styles/PublicChannelPage.module.css';
import batAbi from "@/constant/batAbi.json";
import erc20Abi from "@/constant/erc20Abi.json";

export default function CryptoPaymentWidget({title, cryptoAddresses, cryptoConstants, previewMode}) {
  const t = useTranslations();
  let intervalId;
  const placeholder = t('publicChannelPage.custom');
  // There shouldn't be more than one of each, but just in case
  const solAddress = cryptoAddresses.filter(address => address.includes('SOL'))[0];
  const ethAddress = cryptoAddresses.filter(address => address.includes('ETH'))[0];
  const addresses = { SOL: solAddress && solAddress[0], ETH: ethAddress && ethAddress[0] };
  const iconOptions = { SOL: 'sol-color', ETH: 'eth-color', BAT: 'bat-color', USDC: 'usdc-color' };
  const defaultAmounts = [1,5,10];
  const ethBatAddress = cryptoConstants.eth_bat_address;
  const solanaBatAddress = cryptoConstants.solana_bat_address;
  const solanaMainUrl = cryptoConstants.solana_main_url;
  const ethUsdcAddress = cryptoConstants.eth_usdc_address;
  const solUsdcAddress = cryptoConstants.solana_usdc_address;

  const dropdownOptions = [];
  if (ethAddress) {
    dropdownOptions.push({
      label: t('publicChannelPage.ethereumNetwork'),
      options: [
        {
          label: t('walletServices.addCryptoWidget.ethereum'),
          subheading: t('publicChannelPage.ethSubheading'),
          value: "ETH", 
          icon: 'eth-color'
        },
        {
          label: t('walletServices.addCryptoWidget.ethereumBAT'),
          subheading: t('publicChannelPage.ethBatSubheading'),
          value: "BAT",
          icon: 'bat-color'
        },
        {
          label: t('publicChannelPage.usdc'),
          subheading: t('publicChannelPage.usdcSubheading'),
          value: "USDC",
          icon: 'usdc-color'
        }
      ]
    })
  }

  if (solAddress) {
    dropdownOptions.push({
      label: t('publicChannelPage.solanaNetwork'),
      options: [
        {
          label: t('walletServices.addCryptoWidget.solana'),
          subheading: t('publicChannelPage.solSubheading'),
          value: "SOL",
          icon: 'sol-color'
        },
        {
          label: t('walletServices.addCryptoWidget.solanaBAT'),
          subheading: t('publicChannelPage.solBatSubheading'),
          value: "splBAT",
          icon: 'bat-color'
        },
        {
          label: t('publicChannelPage.solUsdc'),
          subheading: t('publicChannelPage.solUsdcSubheading'),
          value: "USDC-SPL",
          icon: 'usdc-color'
        }
      ]
    })
  }
  // the channel must have at least one crypto address for this page to be navigable,
  // and right now the options are only sol and eth
  const [currentChain, setCurrentChain] = useState(ethAddress ? 'BAT' : 'splBAT');
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
  const [selectValue, setSelectValue] = useState(dropdownOptions.flatMap(opt => opt.options).filter(opt => opt.value === currentChain)[0])

  useEffect(() => {
    loadData();

    if (!previewMode) {
      // Set up a setInterval to fetch new price data every 5 minutes (300,000 milliseconds)
      intervalId = setInterval(backgroundLoadData.bind(this), 300000);
    }
  }, []);

  async function backgroundLoadData() {
    const ratioData = await apiRequest(`get_ratios`);
    setRatios(ratioData);
  }

  async function loadData() {
    setIsLoading(true);
    const ratioData = await apiRequest(`get_ratios`);
    setRatios(ratioData);
    setIsLoading(false);
  };

  function calculateUSDPrice() {
    if (displayChain.includes('USDC')) {
      return Math.round(currentAmount * 100) / 100;
    } else {
      return Math.round(currentAmount * ratios[displayChain.toLowerCase()]['usd'] * 100) / 100;
    }
  };

  function calculateCryptoPrice(usd) {
    if (displayChain.includes('USDC')) {
      return usd;
    } else {
      return usd / ratios[displayChain.toLowerCase()]['usd'];
    }
  }

  function roundCryptoPrice() {
    return Math.round(currentAmount * 100000) / 100000;
  };

  function baseChain() {
    if (currentChain.toLowerCase().includes('spl') || currentChain.includes('SOL')) {
      return 'SOL';
    } else {
      return 'ETH';
    }
  };

  async function sendPayment() {
    clearError();
    switch(currentChain) {
      case 'ETH':
        await sendEthPayment();
        break;
      case 'SOL':
        sendSolPayment();
        break;
      case 'BAT': 
        sendEthBatPayment();
        break;
      case 'splBAT':
        sendSolBatPayment();
        break;
      case 'USDC':
        sendEthUsdcPayment();
        break;
      case 'USDC-SPL':
        sendSolUsdcPayment();
        break;
      default:
        setGenericError();
    }
  };

  function setGenericError() {
    setErrorTitle(t('publicChannelPage.ErrorTitle'));
    setErrorMsg(t('publicChannelPage.ErrorMsg'));
  };

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
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      const address = accounts[0]
      if (!address) {
        setGenericError();
        return;
      }

      // While most guides to converting eth to wei multiply the value by 10e18, In javascript e counts 
      // as the 10 and *10e18 results in a value that is an order of mangitude too high.
      const value = Web3.utils.toHex(Web3.utils.toBigInt(Math.round(currentAmount*10e17)));

      const params = [{
        from: address,
        to: addresses.ETH,
        value: value
      }];

      const transaction = window.ethereum
        .request({
          method: 'eth_sendTransaction',
          params,
        })
        .then((result) => {
          setIsSuccessView(true)
        })
        .catch((error) => {
          setGenericError();
        });
    } else {
      setIsTryBraveModalOpen(true);
      setError('publicChannelPage.noEthTitle', 'publicChannelPage.noEthMsg')
      return;
    }
  }

  async function sendEthTokenPayment(contractAddress, amount, abi) {
    if (typeof window !== 'undefined' && window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      const address = accounts[0];
      if (!address) {
        setGenericError();
        return;
      }

      try {
        const web3 = new Web3(window.ethereum);
        const contract = new web3.eth.Contract(abi, contractAddress);
        const encodedAbi = await contract.methods.transfer(addresses.ETH, amount).encodeABI();
        const gasPrice = await web3.eth.getGasPrice();

        const transaction = {
                          from: address,
                          to: contractAddress,
                          value: "0",  // note that value is a string
                          data: encodedAbi,
                          gasPrice
                        }
        const gasEstimate = await web3.eth.estimateGas(transaction);
        const results = await web3.eth.sendTransaction({ ...transaction, gas: gasEstimate + Web3.utils.toBigInt(450000) })
        
        if (results.status > 0) {
          setIsSuccessView(true);
        }
      } catch (e) {
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
    const amount = Web3.utils.toBigInt(Math.round(currentAmount*10e17));
    await sendEthTokenPayment(ethBatAddress, amount, batAbi);
  }

  async function sendEthUsdcPayment() {
    // USDC token needs 6 decimal places, not 18
    const amount = Web3.utils.toBigInt(Math.round(currentAmount*10e5));
    await sendEthTokenPayment(ethUsdcAddress, amount, erc20Abi);
  }

  async function sendSolPayment() {
    if (typeof window !== 'undefined' && !window.solana) {
      setIsTryBraveModalOpen(true);
      setError('publicChannelPage.noSolTitle', 'publicChannelPage.noSolMsg');
      return;
    } else {
      const provider = await window.solana.connect();
      if (provider.publicKey) {
        const pub_key = provider.publicKey
        const connection = new Connection(solanaMainUrl);
        const amount = Math.round(currentAmount * LAMPORTS_PER_SOL)
        
        const transaction = new Transaction().add(
          SystemProgram.transfer({
            fromPubkey: pub_key,
            toPubkey: addresses.SOL,
            lamports: amount,
          })
        );
        transaction.feePayer = pub_key;
        const blockhashObj = await connection.getLatestBlockhash('confirmed');
        transaction.recentBlockhash = await blockhashObj.blockhash;

        try {
          const result = await window.solana.signAndSendTransaction(transaction);
          if ( result.signature ) {
            window.solana.disconnect();
            setIsSuccessView(true);
          }
        } catch (e) {
          setGenericError();
          window.solana.disconnect()
        }
      } else {
        setGenericError();
        return;
      }
    }
  }

  async function sendSolTokenPayment(contractAddress, decimal) {
    if (typeof window !== 'undefined' && !window.solana) {
      setIsTryBraveModalOpen(true);
      setError('publicChannelPage.noSolTitle', 'publicChannelPage.noSolMsg');
      return;
    } else {
      const provider = await window.solana.connect();

      if (provider.publicKey) {
        try {
          // This is the account address of the user who is sending bat
          const sourceAccountOwner = provider.publicKey
          // multiply the number of bat tokens to the power of the decimals in the token program 
          const amount = Math.round(currentAmount * Math.pow(10, decimal));
          // this is the account address that will receive bat
          const destinationAccountOwner = new PublicKey(addresses.SOL)
          const connection = new Connection(solanaMainUrl)
          const contract = new PublicKey(contractAddress)
          // Check to see if the sender has an associated token account
          const senderAccount = await connection.getParsedTokenAccountsByOwner(sourceAccountOwner, {
            mint: contract,
          });

          if (senderAccount.value.length > 0) {
            const senderTokenAddress = senderAccount.value[0].pubkey;
            // get receiver associated token account

            const destinationAccount = await connection.getParsedTokenAccountsByOwner(destinationAccountOwner, {
              mint: contract,
            });
            // Does the receiver token account already exist?
            const hasDestinationAccount = destinationAccount.value.length > 0;
            // Get the receiver token address, whether it exists or not
            const destinationTokenAddress = hasDestinationAccount ? destinationAccount.value[0].pubkey : await getAssociatedTokenAddress(contract, destinationAccountOwner);
            
            const tx = new Transaction();
            // if the token accout has not been created, add an instruction to create it
            if (!hasDestinationAccount) {
              tx.add(createAssociatedTokenAccountInstruction(
                sourceAccountOwner,
                destinationTokenAddress,
                destinationAccountOwner,
                contract,
              ))
            }
            // Add the instruction to transfer the tokens
            tx.add(createTransferInstruction(
              senderTokenAddress,
              destinationTokenAddress,
              sourceAccountOwner,
              amount
            ));

            tx.feePayer = sourceAccountOwner;
            const latestBlockHash = await connection.getLatestBlockhash('confirmed');
            tx.recentBlockhash = latestBlockHash.blockhash;

            const signature = await window.solana.signAndSendTransaction(tx);

            if ( signature.signature ) {
              window.solana.disconnect();
              setIsSuccessView(true);
            }
          } else {
            setError('publicChannelPage.ErrorTitle', 'publicChannelPage.insufficientBalance');
            window.solana.disconnect();
            return;
          }
        } catch (e) {
          setGenericError();
          window.solana.disconnect()
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

  async function sendSolUsdcPayment () {
    await sendSolTokenPayment(solUsdcAddress, 6);
  }

  function changeChain(optionVal) {
    setCurrentChain(optionVal.value);
    setSelectValue(optionVal)
    SetDisplayChain(optionVal.value.includes('BAT') ? 'BAT' :
                        optionVal.value.includes('USDC') ? 'USDC' :
                        optionVal.value);
    clearError();
  }
  
  function updateAmount(amount) {
    if (!displayCrypto) {
      setCurrentAmount(calculateCryptoPrice(amount));
    } else {
      setCurrentAmount(amount);
    }
  }

  function handleInputChange(event) {
    const customValue = event.target.value ? parseFloat(event.target.value) : null;
    setCustomAmount(customValue);
    if (!displayCrypto) {
      setCurrentAmount(calculateCryptoPrice(customValue));
    } else {
      setCurrentAmount(customValue);
    }
  }

  function handleDisplayCryptoChange() {
    setDisplayCrypto(!displayCrypto);
    displayCrypto ? setCustomAmount(calculateUSDPrice()) : setCustomAmount(currentAmount);
  }
  
  if (isLoading) {
    return (<div className={`${styles['crypto-widget-wrapper']}`}></div>)
  } else if (isSuccessView) {
    return ( <SuccessWidget setStateToStart={() => setIsSuccessView(false)} amount={roundCryptoPrice()} chain={displayChain} name={title} /> )
  } else {
    return (
      <div className={`${styles['crypto-widget-wrapper']}`}>
        <div className={`${styles['heading-wrapper']}`}>
          <div className='default-regular'>
            {t("publicChannelPage.paymentSubHeading")}
          </div>
          <h3 className={`${styles['widget-heading']}`}>
            {t("publicChannelPage.paymentHeading")}
          </h3>
        </div>
        <div className={`${styles['payment-options']}`}>
          <Select
              options={dropdownOptions}
              onChange={changeChain}
              components={{
                SingleValue: ({ children, ...rest }) => (
                  <components.SingleValue {...rest} className='flex'>
                    <Icon name={`${iconOptions[displayChain]}`} className={`mr-2 ${styles['value-icon-image']}`}/>
                    <div>
                      {children}
                      <div className={`${styles['crypto-option-subheading']}`}>{rest.data.subheading}</div>
                    </div>
                  </components.SingleValue>
                ),
                Option: CryptoPaymentOption
              }}
              className='crypto-currency-dropdown'
              value={selectValue}
              styles={{
                control: (base) => ({ ...base,
                  boxShadow: 'none',
                  borderColor: 'rgba(161, 178, 186, 0.4)',
                  padding: '0px 16px',
                  borderRadius: '8px'
                }),
                groupHeading: (base) => ({...base,
                  textAlign: 'left',
                  fontSize: '11px',
                  backgroundColor: 'rgba(243, 245, 247, 1)',
                  padding: '12px 16px',
                }),
                group: (base) => ({...base, padding: '0px'}),
                indicatorSeparator: (base) => ({...base, display: 'none'}),
                dropdownIndicator: (base) => ({...base,
                  padding: '0px',
                  color: 'rgba(98, 117, 126, 1)',
                }),
                input: (base) => ({...base, caretColor: 'transparent' }),
                valueContainer: (base) => ({ ...base,
                  display: 'flex',
                  textAlign: 'left',
                  padding: '16px',
                  paddingLeft: '0px',
                  fontWeight: '600',
                }),
                menu: (base) => ({
                  ...base,
                  marginTop: '0px',
                  borderRadius: '8px',
                  boxShadow: '0px 4px 16px -2px rgba(0, 0, 0, 0.1), 0px 1px 0px 0px rgba(0, 0, 0, 0.05)',
                  overflow: 'hidden',
                }),
                menuList: (base) => ({
                  ...base,
                  maxHeight: '500px',
                  paddingTop: '0px',
                }),
              }}
            />
          <div className="grid grid grid-cols-12 pb-4 pt-4">
            <div className="col-span-12 md:col-span-7 text-left">
              {!displayCrypto && defaultAmounts.map( amount => {
                return(
                  <button
                    key={amount}
                    className={`${calculateUSDPrice() === amount ? styles['selected'] : ''} ${styles['amount-button']}`}
                    onClick={() => updateAmount(amount)}
                  > 
                    $ {amount}
                  </button>
                )
              })}
              <input
                type="number"
                onChange={handleInputChange}
                className={`${currentAmount === customAmount ? styles['selected'] : ''} ${displayCrypto ? styles['amount-full-width'] : ''} ${styles['amount-input']}`}
                placeholder={placeholder}
                value={customAmount}
              />
            </div>
            <div className="col-span-12 md:col-span-5 text-right align-top">
              <h2 className={`${styles['large-currency-display']}`}>
                {displayCrypto ? (
                    <span>{roundCryptoPrice()} <span className={`${styles['currency']} align-middle`}>{displayChain}</span></span>
                  ) : (
                    <span>${calculateUSDPrice()} <span className={`${styles['currency']} align-middle`}>USD</span></span>
                  )}
              </h2>
              <div className={`${styles['small-currency-display']}`}>
                {!displayCrypto ? (
                    <span>{roundCryptoPrice()} {displayChain}</span>
                  ) : (
                    <span>${calculateUSDPrice()} USD</span>
                  )}
              </div>
              <div onClick={() => handleDisplayCryptoChange()} className={`${styles['exchange-icon']}`}></div>
            </div>
          </div>
          {errorTitle && (
            <div className={`${styles['error-section']}`}>
              <div className={`${styles['error-icon']}`}><Icon name='warning-circle-filled' /></div>
              <div className={`${styles['error-text']}`}>
                <div className={`${styles['error-title']}`}>{errorTitle}</div>
                <div className={`${styles['error-message']}`}>{errorMsg}</div>
              </div>
            </div>
          )}
        </div>
        <div className={`${styles['payment-buttons']}`}>
          <Button onClick={(event) => {
              event.preventDefault();
              sendPayment();
            }}
            isDisabled={currentAmount <= 0 || previewMode}
            className={`mb-3 ${styles['send-button']}`}
          >
            {t("publicChannelPage.send")}
          </Button>
          
          <a 
            className={`${styles['qr-link']}`}
            onClick={(event) => {
            event.preventDefault();
            setIsModalOpen(true);
          }}>
            {t("publicChannelPage.generateQR")}
          </a>
        </div>
        <Dialog
          isOpen={isModalOpen}
          showClose={true}
          onClose={() => setIsModalOpen(false)}
          className={`${styles['qr-modal']}`}
        >
          <QRCodeModal
            address={addresses[baseChain()]}
            chain={baseChain()}
            displayChain={displayChain}
          />
        </Dialog>
        <Dialog
          isOpen={isTryBraveModalOpen}
          showClose={true}
          onClose={() => isTryBraveModalOpen(false)}
          className={`${styles['try-brave-modal']}`}
        >
          <TryBraveModal />
        </Dialog>
      </div>
    )
  }
}
