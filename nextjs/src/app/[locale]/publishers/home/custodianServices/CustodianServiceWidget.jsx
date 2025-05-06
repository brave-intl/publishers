'use client';

import Button from '@brave/leo/react/button';
import Icon from '@brave/leo/react/icon';
import Link from '@brave/leo/react/link';
import Dialog from '@brave/leo/react/dialog';
import Image from 'next/image';
import { useLocale, useTranslations } from 'next-intl';
import { useState, useContext } from 'react';

import { apiRequest } from '@/lib/api';

import styles from '@/styles/ChannelCard.module.css';
import DisconnectConfirmationModal from './DisconnectConfirmationModal';
import CustodianConnectModal from './CustodianConnectModal';
import { CustodianConnectionContext } from '@/lib/context/CustodianConnectionContext';

export default function CustodianServiceWidget({}) {
  const t = useTranslations();
  const locale = useLocale();
  const supportUrl = locale !== 'ja' ? 'https://support.brave.com/hc/en-us/articles/9884338155149' : 'https://support.brave.com/hc/en-us/articles/23311539795597';

  const {bitflyerConnection, setBitflyerConnection, upholdConnection, setUpholdConnection, geminiConnection, setGeminiConnection} = useContext(CustodianConnectionContext);
  const [isConfirmationModalOpen, setIsConfirmationModalOpen] = useState(false);
  const [isCustodianConnectModalOpen, setIsCustodianConnectModalOpen] = useState(false);

  const providerUpdaters = {
    gemini: setGeminiConnection,
    uphold: setUpholdConnection,
    bitflyer: setBitflyerConnection,
  };

  const providerWebsites = {
    gemini: 'https://exchange.gemini.com/',
    uphold: 'https://wallet.uphold.com/',
    bitflyer: 'https://bitflyer.com/',
  }

  async function disconnectProvider(provider) {
    const res = await apiRequest(
      `connection/${provider}_connection`,
      'DELETE',
      {},
    );
    if (!res.errors) {
      providerUpdaters[provider].call(null);
      setIsConfirmationModalOpen(false);
    } else {
      // show error state here?
    }
  }

  function launchCustodianModal() {
    setIsCustodianConnectModalOpen(true);
  }

  function providerIcon(provider) {
    if (provider === 'gemini') {
      return <Icon><Image src="/images/gemini-color.svg" width="24" height="24" /></Icon>;
    } else {
      return <Icon name={`${provider}-color`} />;
    }
  }

  function showConnected(provider) {
    return (
      <section>
        <div className='small-semibold pb-0.5'>{t('Home.account.custodial_account')}</div>
        <div className={`pb-2 xl:pb-0 flex justify-between ${styles['faux-btn']}`}>
          <div className='flex items-center'>
            <span className='inline-block align-middle'>
              {providerIcon(provider)}
            </span>
            <span className='inline-block align-middle px-1'>
              {t(`shared.${provider}`)}
            </span>
          </div>
          <Link href={providerWebsites[provider]} className='color-tertiary pr-1'>
            <Icon name='launch' className='color-tertiary'/>
          </Link>
        </div>
        <div className='mt-0.5 small-regular color-tertiary'>
          <Link
            className={styles['disconnect-btn']}
            onClick={() => {
              setIsConfirmationModalOpen(true);
            }}
          >
            {t('walletServices.disconnect')}
          </Link>
          <span> - {t('Home.account.disconnect_warning')}</span>
        </div>
        <Dialog
          isOpen={isConfirmationModalOpen}
          onClose={() => setIsConfirmationModalOpen(false)}
          showClose={true}
        >
          <DisconnectConfirmationModal close={disconnectProvider} provider={provider} />
        </Dialog>

      </section>
    );
  }

  function showUnconnected() {
    return (
      <section>
        <div className='small-semibold pb-0.5'>{t('Home.account.custodial_account')}</div>
        <div className={`pb-2 xl:pb-0 flex justify-between cursor-pointer ${styles['faux-btn']}`} onClick={launchCustodianModal} >
          <div className='pl-0.5 color-secondary'>
            {t('Home.account.not_connected')}
          </div>
          <Icon name='launch' className='color-tertiary'/>
        </div>
        <div className='mt-0.5 small-regular color-tertiary'>
          {t('Home.account.connect_warning')}
          <a
            href={supportUrl}
            rel='noopener noreferrer'
            target='_blank'
            className='underline'
          >
            {t('shared.learn_more')}
          </a>
        </div>
        <Dialog
          isOpen={isCustodianConnectModalOpen}
          onClose={() => setIsCustodianConnectModalOpen(false)}
          showClose={true}
        >
          <CustodianConnectModal />
        </Dialog>
      </section>
    );
  }

  if (bitflyerConnection) {
    return showConnected('bitflyer');
  } else if (upholdConnection && upholdConnection.uphold_id) {
    return showConnected('uphold');
  } else if (geminiConnection && geminiConnection.display_name) {
    return showConnected('gemini');
  } else {
    return showUnconnected();
  }
}
