'use client';

import Button from '@brave/leo/react/button';
import Dropdown from '@brave/leo/react/dropdown';
import Icon from '@brave/leo/react/icon';
import Link from '@brave/leo/react/link';
import { useLocale, useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import countryList from './countryList.json';
import styles from '@/styles/Dashboard.module.css';

export default function CustodianServiceWidget({ walletData }) {
  const t = useTranslations();
  const locale = useLocale();
  const supportedRegions = walletData.allowed_regions;
  const [selectedCountry, setSelectedCountry] = useState(undefined);
  const [unsupportedCountry, setUnsupportedCountry] = useState(false);
  const [upholdConnection, setUpholdConnection] = useState(walletData.uphold_connection);
  const [geminiConnection, setGeminiConnection] = useState(walletData.gemini_connection);
  const [bitflyerConnection, setBitflyerConnection] = useState(walletData.bitflyer_connection);

  const supportUrl = locale !== 'ja' ? 'https://support.brave.com/hc/en-us/articles/9884338155149' : 'https://support.brave.com/hc/en-us/articles/23311539795597';


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

  useEffect(() => {
    if (
      supportedRegions.uphold.allow.includes(countryList[selectedCountry]) ||
      supportedRegions.gemini.allow.includes(countryList[selectedCountry]) ||
      supportedRegions.bitflyer.allow.includes(countryList[selectedCountry])
    ) {
      setUnsupportedCountry(false);
    } else {
      setUnsupportedCountry(true);
    }
  }, [selectedCountry]);

  function handleCountryChange({ value }) {
    setSelectedCountry(value);
    return value;
  }

  async function redirectToAuthUrl(provider) {
    const res = await apiRequest(
      `connection/${provider}_connection`,
      'POST',
      {},
    );
    window.location.assign(res.authorization_url);
  }

  async function disconnectProvider(provider) {
    const res = await apiRequest(
      `connection/${provider}_connection`,
      'DELETE',
      {},
    );
    if (!res.errors) {
      providerUpdaters[provider].call(null);
    } else {
      // show error state here?
    }
  }

  function capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  }

  function showConnected(provider) {
    return (
      <section className='grid xl:grid-cols-2'>
        <div className='xl:pb-2'>{t('Home.account.connected_account')}</div>
        <div className='pb-2 xl:pb-0 flex items-start'>
          <span className='inline-block'>
            <Icon name={`${provider}-color`} />
          </span>
          <span className='px-1'>
            <strong>{t(`shared.${provider}`)}</strong>
          </span>
          <Link href={providerWebsites[provider]} className='color-tertiary pr-1'>
            <Icon name='launch' className='color-tertiary'/>
          </Link>
          |
          <Link
            className={`pl-1 ${styles['disconnect-btn']}`}
            onClick={() => {
              disconnectProvider(provider);
            }}
          >
            Disconnect
          </Link>
        </div>
        <div className='xl:pb-2'>{t('Home.account.deposit_currency')}</div>
        <div className='pb-2 xl:pb-0 flex items-start'>
          <span className='inline-block'>
            <Icon name='bat-color' />
          </span>
          <span className='px-1'>
            <strong>BAT</strong>
          </span>
          <span>{t('shared.basic_attention_token')}</span>
        </div>
      </section>
    );
  }

  function showUnconnected() {
    return (
      <section>
        <p className='pb-3'>{t('Home.account.connect_prompt')}</p>
        {locale !== 'ja' && (
          <Dropdown
            size='normal'
            value={selectedCountry}
            className='w-full'
            placeholder={t('Home.account.country_placeholder')}
            onChange={handleCountryChange}
          >
            <div className='small-semibold' slot="label">{t('Home.account.country_label')}</div>
            {selectedCountry && (
              <div slot="left-icon">
                <Icon name={`country-${countryList[selectedCountry].toLowerCase()}`} />
              </div>
            )}
            {Object.keys(countryList).map(function (countryName) {
              return (
                <leo-option
                  className='py-0'
                  key={countryList[countryName]}
                  value={countryName}
                >
                  <Icon
                    className='inline-block'
                    name={`country-${countryList[countryName].toLowerCase()}`}
                  />
                  <div className='px-1 inline-block align-top'>{countryName}</div>
                </leo-option>
              );
            })}
          </Dropdown>
        )}
        {selectedCountry && (
          <div className='pt-3'>
            <p className='small-semibold mb-0.5'>
              {t('Home.account.custodial_select_heading')}
            </p>
            <Button
              onClick={() => redirectToAuthUrl('uphold')}
              kind='outline'
              className='mr-1'
            >
              <Icon className='color-tertiary' name="uphold-color" slot="icon-before" />
              {t('Home.account.uphold_connect')}
              <Icon name="launch" slot="icon-after" />
            </Button>
            <Button
              onClick={() => redirectToAuthUrl('gemini')}
              kind='outline'
            >
              <Icon name="gemini-color" slot="icon-before" />
              {t('Home.account.gemini_connect')}
              <Icon name="launch" slot="icon-after" />
            </Button>
            {unsupportedCountry && (
              <div className='info-text mt-3'>
                {t('Home.account.wrong_region', { region: selectedCountry })}
              </div>
            )}
          </div>
        )}
        {locale === 'ja' && (
          <Button
            onClick={() => redirectToAuthUrl('bitflyer')}
            kind='outline'
          >
            <Icon name="bitflyer-color" slot="icon-before" />
            {t('Home.account.bitflyer_connect')}
            <Icon name="launch" slot="icon-after" />
          </Button>
        )}
        <p className='small-regular color-tertiary pt-3'>
          {t('Home.account.country_disclaimer')}
          <a
            href={supportUrl}
            rel='noopener noreferrer'
            target='_blank'
            className='underline'
          >
            {t('shared.learn_more')}.
          </a>
        </p>
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
