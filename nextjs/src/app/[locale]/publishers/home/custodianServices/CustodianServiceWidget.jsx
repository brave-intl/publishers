'use client';

import Button from '@brave/leo/react/button';
import Dropdown from '@brave/leo/react/dropdown';
import Icon from '@brave/leo/react/icon';
import Link from '@brave/leo/react/link';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import * as countryList from './countryList.json';

export default function CustodianServiceWidget({ walletData }) {
  const t = useTranslations();
  const supportedRegions = walletData.allowed_regions;
  const [selectedCountry, setSelectedCountry] = useState(undefined);
  const [unsupportedCountry, setUnsupportedCountry] = useState(false);
  const [upholdConnection, setUpholdConnection] = useState(null);
  const [geminiConnection, setGeminiConnection] = useState(null);
  const [bitflyerConnection, setBitflyerConnection] = useState(null);

  const providerUpdaters = {
    gemini: setGeminiConnection,
    uphold: setUpholdConnection,
    bitflyer: setBitflyerConnection,
  };

  useEffect(() => {
    if (
      supportedRegions.uphold.allow.includes(selectedCountry) ||
      supportedRegions.gemini.allow.includes(selectedCountry) ||
      supportedRegions.bitflyer.allow.includes(selectedCountry)
    ) {
      setUnsupportedCountry(false);
    } else {
      setUnsupportedCountry(true);
    }
  }, [selectedCountry]);

  function handleCountryChange(e) {
    setSelectedCountry(e.detail.value);
    return e.detail.value;
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
      <section className='grid grid-cols-2'>
        <div>{t('Home.account.connected_account')}</div>
        <div className='flex items-center'>
          <span className='inline-block'>
            <Icon name={`${provider}-color`} />
          </span>
          <span className='px-1'>{capitalize(provider)} -</span>
          <Link href=''>Open</Link>
          <Link
            className='pl-1'
            onClick={() => {
              disconnectProvider(provider);
            }}
          >
            Disconnect
          </Link>
        </div>
        <div>{t('Home.account.deposit_currency')}</div>
        <div className='flex items-center'>
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
        <p>{t('Home.account.connect_prompt')}</p>
        <Dropdown
          size='normal'
          value={selectedCountry}
          className='w-full'
          label={t('Home.account.country_label')}
          placeholder={t('Home.account.country_placeholder')}
          onChange={handleCountryChange}
          left-icon={selectedCountry && selectedCountry.toLowerCase()}
        >
          {countryList.map(function (country) {
            return (
              <leo-option
                className='flex items-center'
                key={country.code}
                value={country.code}
              >
                <Icon
                  className='inline-block'
                  name={`country-${country.code.toLowerCase()}`}
                />
                <span className='px-1'>{country.name}</span>
              </leo-option>
            );
          })}
        </Dropdown>
        {selectedCountry && (
          <div>
            <p className='font-small'>
              {t('Home.account.custodial_select_heading')}
            </p>
            <Button
              onClick={() => redirectToAuthUrl('uphold')}
              kind='outline'
              icon-before='uphold-color'
            >
              {t('Home.account.uphold_connect')}
            </Button>
            <Button
              onClick={() => redirectToAuthUrl('gemini')}
              kind='outline'
              icon-before='gemini-color'
            >
              {t('Home.account.gemini_connect')}
            </Button>
            {unsupportedCountry && (
              <div className='info-box'>
                {t('Home.account.wrong_region', { region: selectedCountry })}
              </div>
            )}
          </div>
        )}
        <p className='font-small'>
          {t.rich('Home.account.country_disclaimer', {
            link: (chunks) => {
              <a
                href='https://support.brave.com/hc/en-us/articles/9884338155149'
                rel='noopener noreferrer'
                target='_blank'
              >
                {chunks}
              </a>;
            },
          })}
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
