'use client';

import Button from '@brave/leo/react/button';
import Dropdown from '@brave/leo/react/dropdown';
import Icon from '@brave/leo/react/icon';
import Select, { components } from "react-select";
import { useLocale, useTranslations } from 'next-intl';
import { useEffect, useState, useContext } from 'react';
import styles from '@/styles/ChannelCard.module.css';
import { CustodianConnectionContext } from '@/lib/context/CustodianConnectionContext';
import countryList from './countryList.json';
import { apiRequest } from '@/lib/api';

export default function CustodianConnectModal({}) {
  const t = useTranslations();
  const locale = useLocale();

  const { allowedRegions } = useContext(CustodianConnectionContext);
  const [selectedCountry, setSelectedCountry] = useState(undefined);
  const [selectedCountryLabel, setSelectedCountryLabel] = useState(undefined)
  const [unsupportedCountry, setUnsupportedCountry] = useState(false);
  const [unsupportedCountryMsg, setUnsupportedCountryMsg] = useState('');
  const supportUrl = locale !== 'ja' ? 'https://support.brave.com/hc/en-us/articles/9884338155149' : 'https://support.brave.com/hc/en-us/articles/23311539795597';

  // Since japanese accounts are limited to bitflyer, translation isn't a concern here. If we add other languages, we might need to revisit this.
  useEffect(() => {
    const unsupportedProvider = [];
    // hard code gemini to us
    if (allowedRegions.uphold.allow.includes(selectedCountry) &&
      ['US'].includes(selectedCountry)
    ) {
      setUnsupportedCountry(false);
    } else {
      setUnsupportedCountry(true);
      !allowedRegions.uphold.allow.includes(selectedCountry) && unsupportedProvider.push('Uphold');
      // hard code gemini to the us
      !['US'].includes(selectedCountry) && unsupportedProvider.push('Gemini');

      setUnsupportedCountryMsg(
        t('Home.account.wrong_region',
          { provider: unsupportedProvider.join(' and '), region: selectedCountryLabel }
        )
      );
    }
  }, [selectedCountry]);

  function handleCountryChange({label, value}) {
    setSelectedCountry(value);
    setSelectedCountryLabel(label);
  }

  async function redirectToAuthUrl(provider) {
    const res = await apiRequest(
      `connection/${provider}_connection`,
      'POST',
      {},
    );
    window.location.assign(res.authorization_url);
  }

  return (
    <section>
      <p className='pb-3'>{t('Home.account.connect_prompt')}</p>
      {locale !== 'ja' && (
        <Select
          options={countryList}
          onChange={handleCountryChange.bind(this)}
          placeholder={t('Home.account.country_placeholder')}
          value={selectedCountry && { label: selectedCountryLabel }}
          components={{
            Option: ({data, innerProps}) => {
              return (
                <div {...innerProps} className={styles['address-option']}>
                  <Icon
                    className='inline-block'
                    name={`country-${data.value.toLowerCase()}`}
                  />
                  <div className='px-1 inline-block align-top'>{data.label}</div>
                </div>
              )
            },
          }}
          isSearchable={true}
          classNames={{
              control: () => `${styles['country-select-dropdown']}`,
              dropdownIndicator: () => `${styles['dropdown-indicator']}`,
              indicatorSeparator: () => `${styles['indicator-separator']}`,
              menu: () => `${styles['menu']}`,
            }}
        />
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
            <Icon className='color-tertiary' name="gemini-color" slot="icon-before" />
            {t('Home.account.gemini_connect')}
            <Icon name="launch" slot="icon-after" />
          </Button>
          {unsupportedCountry && (
            <div className='info-text mt-3'>
              {unsupportedCountryMsg}
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
      {/* force dialog to be 'taller' and allow space for the dropdown */}
      <div className={styles['dialog-pad']}></div>
    </section>
  )
}
