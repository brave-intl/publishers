'use client';

import Dialog from '@brave/leo/react/dialog';
import ProgressRing from '@brave/leo/react/progressRing';
import bs58 from 'bs58';
import { useTranslations } from 'next-intl';
import { useContext, useEffect, useState } from 'react';
import Select from 'react-select';

import styles from '@/styles/ChannelCard.module.css';

import { apiRequest } from '@/lib/api';
import UserContext from '@/lib/context/UserContext';

import { CryptoAddressContext } from '@/components/CryptoAddressProvider';

import CryptoPrivacyModal from './CryptoPrivacyModal';
import CryptoWalletOption from './CryptoWalletOption';

export default function ChannelCryptoEditor({ channel }) {
  const t = useTranslations();
  const {
    addressesInUse,
    currentResponseData,
    addAddressInUse,
    removeAddressInUse,
    updateResponseData,
  } = useContext(CryptoAddressContext);
  const { user } = useContext(UserContext);
  const [ethOptions, setEthOptions] = useState([]);
  const [solOptions, setSolOptions] = useState([]);
  const [currentSolAddress, setCurrentSolAddress] = useState(null);
  const [currentEthAddress, setCurrentEthAddress] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorText, setErrorText] = useState(null);
  const [pendingAddress, setPendingAddress] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    const newEthOptions = formatOptionData(
      currentResponseData,
      currentEthAddress,
      'ETH',
    );
    const newSolOptions = formatOptionData(
      currentResponseData,
      currentSolAddress,
      'SOL',
    );
    setEthOptions(newEthOptions);
    setSolOptions(newSolOptions);

    if (
      currentSolAddress &&
      newSolOptions.filter(
        (sol) => sol.value.address === currentSolAddress.value.address,
      ).length < 1
    ) {
      setCurrentSolAddress(null);
    }
    if (
      currentEthAddress &&
      newEthOptions.filter(
        (eth) => eth.value.address === currentEthAddress.value.address,
      ).length < 1
    ) {
      setCurrentEthAddress(null);
    }
  }, [currentResponseData]);

  // Helper functions
  function formatOptionData(response, currentAddress, chain) {
    const options = response
      .filter((address) => address.chain === chain)
      .map((address) => {
        return { value: address, label: address.address };
      });

    options.push({
      label: t('Home.addCryptoWidget.addWallet'),
      value: { newAddress: chain },
    });
    options.push({
      label: t('Home.addCryptoWidget.clearWallet'),
      value: { clearAddress: chain, deletedAddress: currentAddress },
    });
    return options;
  }

  function findCurrentAddress(chain, channelResponse, allResponse) {
    const current = channelResponse.filter(
      (address) => address.chain === chain,
    )[0];
    if (current) {
      const found = allResponse
        .filter((address) => address.chain === chain)
        .find((address) => address.id === current.crypto_address_id);
      return found
        ? { label: formatCryptoAddress(found.address), value: found }
        : null;
    }
    return null;
  }

  function formatCryptoAddress(address) {
    return `${address.slice(0, 6)}****${address.slice(-4)}`;
  }

  // setup the dropdowns
  async function loadData() {
    setIsLoading(true);

    // clear out old addresses before adding them back to the store
    if (currentEthAddress) {
      removeAddressInUse({ removedAddress: currentEthAddress.value.id });
    }
    if (currentSolAddress) {
      removeAddressInUse({ removedAddress: currentSolAddress.value.id });
    }

    const response = await apiRequest(`publishers/${user.id}/crypto_addresses`);
    updateResponseData(response);

    const channelResponse = await apiRequest(
      `channels/${channel.id}/crypto_address_for_channels`,
    );
    const solAddress = findCurrentAddress('SOL', channelResponse, response);
    const ethAddress = findCurrentAddress('ETH', channelResponse, response);
    setCurrentSolAddress(solAddress);
    setCurrentEthAddress(ethAddress);

    if (solAddress) {
      addAddressInUse({ newAddress: solAddress.value });
    }

    if (ethAddress) {
      addAddressInUse({ newAddress: ethAddress.value });
    }

    setEthOptions(formatOptionData(response, ethAddress, 'ETH'));
    setSolOptions(formatOptionData(response, solAddress, 'SOL'));

    setErrorText(null);
    setIsLoading(false);
  }

  // crypto connection functions
  async function getNonce() {
    const response = await apiRequest(
      `channels/${channel.id}/crypto_address_for_channels/generate_nonce`,
    );
    return response.nonce;
  }

  async function connectSolanaAddress() {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    if (!window.solana) {
      // setIsTryBraveModalOpen(true);
      setErrorText(t('Home.addCryptoWidget.solanaConnectError'));
      return false;
    }
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    const results = await window.solana.connect();
    if (results.publicKey) {
      const pub_key = results.publicKey;

      const possibleMatch = solOptions.filter(
        (sol) => sol.value.address === pub_key,
      );
      if (possibleMatch.length > 0) {
        if (
          addressesInUse.filter(
            (usedAddress) => usedAddress.address === pub_key,
          ).length > 0
        ) {
          launchPrivacyModal(possibleMatch[0].value);
        } else {
          await updateAddress(possibleMatch[0].value);
        }
        return;
      }

      const nonce = await getNonce();
      if (!nonce) {
        setErrorText(t('Home.addCryptoWidget.genericError'));
        return;
      }
      const encodedMessage = new TextEncoder().encode(nonce);
      let signedMessage = null;

      try {
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        signedMessage = await window.solana.signMessage(encodedMessage, 'utf8');
      } catch (err) {
        setErrorText(t('Home.addCryptoWidget.solanaConnectionFailure'));
        return;
      }

      const response = await apiRequest(
        `channels/${channel.id}/crypto_address_for_channels`,
        'POST',
        {
          chain: 'SOL',
          account_address: pub_key,
          message: nonce,
          transaction_signature: bs58.encode(signedMessage.signature),
        },
      );
      handleConnectionResponse(response);
    }
  }

  async function connectEthereumAddress() {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    if (window.ethereum) {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });
      const address = accounts[0];
      if (!address) {
        setErrorText(t('Home.addCryptoWidget.ethereumConnectError'));
        return;
      }

      const possibleMatch = ethOptions.filter(
        (eth) =>
          eth.value.address &&
          eth.value.address.toLowerCase() === address.toLowerCase(),
      );
      if (possibleMatch.length > 0) {
        if (
          addressesInUse.filter(
            (usedAddress) => usedAddress.address === address,
          ).length > 0
        ) {
          launchPrivacyModal(possibleMatch[0].value);
        } else {
          await updateAddress(possibleMatch[0].value);
        }
        return;
      }

      const nonce = await getNonce();
      if (!nonce) {
        setErrorText(t('Home.addCryptoWidget.genericError'));
        return;
      }
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      const signature = await window.ethereum.request({
        method: 'personal_sign',
        params: [address, nonce],
      });

      const response = await apiRequest(
        `channels/${channel.id}/crypto_address_for_channels`,
        'POST',
        {
          chain: 'ETH',
          account_address: address,
          message: nonce,
          transaction_signature: signature,
        },
      );
      handleConnectionResponse(response);
    } else {
      // setIsTryBraveModalOpen(true);
      setErrorText(t('Home.addCryptoWidget.ethereumConnectError'));
      return;
    }
  }

  // UI helpers for api responses
  function handleConnectionResponse(response) {
    if (response.errors) {
      setErrorText(t('Home.addCryptoWidget.addressConnectFailure'));
    } else {
      loadData();
    }
  }

  // Crud functions
  async function changeAddress(optionValue) {
    const address = optionValue.value;
    if (address.newAddress === 'SOL') {
      await connectSolanaAddress();
    } else if (address.newAddress === 'ETH') {
      await connectEthereumAddress();
    } else if (address.clearAddress) {
      await clearAddress(address.deletedAddress.value);
    } else if (address.chain && address.address) {
      if (
        addressesInUse.filter((usedAddress) => usedAddress.id === address.id)
          .length > 0
      ) {
        launchPrivacyModal(address);
      } else {
        await updateAddress(address);
      }
    }
  }

  async function updateAddress(address) {
    const response = await apiRequest(
      `channels/${channel.id}/crypto_address_for_channels/change_address`,
      'POST',
      { ...address },
    );
    handleConnectionResponse(response);
  }

  async function deleteAddress(address) {
    const response = await apiRequest(
      `publishers/${user.id}/crypto_addresses/${address.id}`,
      'DELETE',
    );
    handleConnectionResponse(response);
  }

  async function clearAddress(address) {
    const response = await apiRequest(
      `channels/${channel.id}/crypto_address_for_channels/${address.id}`,
      'DELETE',
      { ...address },
    );
    handleConnectionResponse(response);
  }

  function launchPrivacyModal(pendingAddress) {
    setPendingAddress(pendingAddress);
    setIsModalOpen(true);
  }

  function closeModal() {
    setPendingAddress(null);
    setIsModalOpen(false);
  }

  if (isLoading) {
    return <ProgressRing />;
  } else {
    return (
      <div className={styles['crypto-wallet-for-channel']}>
        <small>{t('Home.addCryptoWidget.widgetTitle')}</small>
        <div className={styles['crypto-wallet-group']}>
          <div className={styles['chain-label']}>
            {t('Home.addCryptoWidget.ethereum')}
          </div>
          <Select
            options={ethOptions}
            onChange={changeAddress.bind(this)}
            components={{
              Option: CryptoWalletOption,
            }}
            placeholder={t('Home.addCryptoWidget.notConnected')}
            value={currentEthAddress}
            deleteAddress={deleteAddress.bind(this)}
            formatCryptoAddress={formatCryptoAddress}
            classNames={{
              control: () =>
                `${styles['crypto-wallet-dropdown']} ${styles['crypto-wallet-dropdown-eth']}`,
              dropdownIndicator: () => `${styles['dropdown-indicator']}`,
              indicatorSeparator: () => `${styles['indicator-separator']}`,
              menu: () => `${styles['menu']}`,
            }}
          />
        </div>
        <div className={styles['crypto-wallet-group']}>
          <div className={styles['chain-label']}>{t('Home.addCryptoWidget.solana')}</div>
          <Select
            options={solOptions}
            onChange={changeAddress.bind(this)}
            components={{
              Option: CryptoWalletOption,
            }}
            placeholder={t('Home.addCryptoWidget.notConnected')}
            value={currentSolAddress}
            deleteAddress={deleteAddress.bind(this)}
            formatCryptoAddress={formatCryptoAddress}
            classNames={{
              control: () =>
                `${styles['crypto-wallet-dropdown']} ${styles['crypto-wallet-dropdown-sol']}`,
              dropdownIndicator: () => `${styles['dropdown-indicator']}`,
              indicatorSeparator: () => `${styles['indicator-separator']}`,
              menu: () => `${styles['menu']}`,
            }}
          />
        </div>
        <div className={styles['alert-warning']}>{errorText}</div>
        {(currentSolAddress || currentEthAddress) && (
          <a href={`/c/${channel.public_identifier}`}>
            {t('Home.addCryptoWidget.channelPageLink')}
          </a>
        )}
        <Dialog isOpen={isModalOpen} onClose={closeModal}>
          <CryptoPrivacyModal
            close={closeModal}
            updateAddress={updateAddress.bind(this)}
            address={pendingAddress}
          />
        </Dialog>
      </div>
    );
  }
}
