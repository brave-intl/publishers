'use client';

import { useEffect, useState } from 'react';
import { useTranslations } from 'next-intl';
import Icon from '@brave/leo/react/icon';
import ProgressRing from '@brave/leo/react/progressRing';
import { apiRequest } from '@/lib/api';

import CryptoPaymentWidget from "./CryptoPaymentWidget";
import styles from '@/styles/PublicChannelPage.module.css';

export default function PublicChannelPage({publicIdentifier, previewMode}) {
  const t = useTranslations();
  const [isLoading, setIsLoading] = useState(true);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [socialLinks, setSocialLinks] = useState({});
  const [logoUrl, setLogoUrl] = useState('');
  const [coverUrl, setCoverUrl] = useState('');
  const [cryptoAddresses, setCryptoAddresses] = useState([]);
  const [cryptoConstants, setCryptoConstants] = useState({});
  const [url, setUrl] = useState('');

  async function fetchChannelData() {
    const channelData = await apiRequest(`public_channel/${publicIdentifier}`);

    const siteBannerData = channelData.site_banner;
    setTitle(siteBannerData.title);
    setDescription(siteBannerData.description);
    setSocialLinks(siteBannerData.socialLinks);
    setLogoUrl(siteBannerData.logoUrl);
    setCoverUrl(siteBannerData.coverUrl);
    setUrl(channelData.url);
    setCryptoAddresses(channelData.crypto_addresses);
    setCryptoConstants(channelData.crypto_constants);
    setIsLoading(false);
  }

  useEffect(() => {
    fetchChannelData();
  }, []);

  function channelIconType(channelType, color = true) {
    if (channelType === 'site') {
      return <Icon className='color-interactive inline-block align-top' name='globe' forceColor={color}/>;
    } else if (channelType === 'twitter') {
      return <Icon className='inline-block align-top' name='social-x' forceColor={color} />;
    } else {
      return <Icon className='inline-block align-top' name={`social-${channelType}`} forceColor={color} />;
    }
  }
  
  if (isLoading) {
    return (
      <div className={`${styles['public-channel-container']}`}>
        <div className="flex basis-full grow items-center justify-center">
          <ProgressRing />
        </div>
      </div>
    )
  } else {
    return (
      <div className={`${styles['public-channel-container']}`}>
        <div className={`${styles['image-container']}`}>
          <div style={{ '--cover-url': `url('${coverUrl}')` }} className={`${styles['cover']}`}></div>
        </div>
        <div className='container mx-auto'>
          <div className='grid grid-cols-1 lg:grid-cols-2'>
            <div className={`${styles['description-container']} px-4`}>
              <div className={`${styles['logo']}`} style={{ '--logo-url': `url('${logoUrl}')` }}></div>
              <h1 className={`${styles['creator-title']}`}>{title} <Icon name='verification-filled-color' className='inline-block' /></h1>
              <div className={`${styles['creator-description']} large-regular`}>{description}</div>
              <div>
                {Object.keys(socialLinks).map((key) => {
                  if (socialLinks[key].length) {
                    return (
                      <a href={socialLinks[key]} 
                               key={key}
                               target="_blank"
                               className={`${styles['social-link']}`}
                               rel="noopener noreferrer">
                        {channelIconType(key)}
                      </a>
                    );
                  }
                })}
              </div>
            </div >
            <div className={`${styles['crypto-payment-container']}`}>
              <CryptoPaymentWidget title={title} cryptoAddresses={cryptoAddresses} cryptoConstants={cryptoConstants} previewMode={previewMode} />
              <div className={`${styles['privacy-disclaimer']}`}>
                {t('publicChannelPage.trustWarning')}
                <a href={url} target="_blank" rel="noopener noreferrer">{url}</a>
              </div>
              <div className={`${styles['privacy-disclaimer']}`}>
                {t('publicChannelPage.privacyDisclaimer')}
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
