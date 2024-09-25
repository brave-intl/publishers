'use client';

import Button from '@brave/leo/react/button';
import ProgressRing from '@brave/leo/react/progressRing';
import Dropdown from '@brave/leo/react/dropdown';
import Icon from '@brave/leo/react/icon';
import Input from '@brave/leo/react/input';
import Link from '@brave/leo/react/link';
import Hr from '@brave/leo/react/hr';
import Dialog from '@brave/leo/react/dialog';

import { useTranslations } from 'next-intl';
import { useSearchParams } from 'next/navigation';
import { useRouter } from 'next/navigation';
import { useEffect, useState, useRef } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';
import Toast from '@/components/Toast';
import Preview from './preview/preview';
import EmptyChannelCard from '../home/channels/EmptyChannelCard';
import styles from '@/styles/ContributionBanner.module.css';

export default function ContributionPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [channel, setChannel] = useState({});
  const [channelList, setChannelList] = useState([]);
  const [title, setTitle] = useState('');
  const [publicIdentifier, setPublicIdentifier] = useState('');
  const [description, setDescription] = useState('');
  const [socialLinks, setSocialLinks] = useState({});
  const [logoUrl, setLogoUrl] = useState('');
  const [coverUrl, setCoverUrl] = useState('');
  const [toastMessage, setToastMessage] = useState('');
  const [previewModalOpen, setPreviewModalOpen] = useState(false);
  const [noChannels, setNoChannels] = useState(false);
  const logoInputRef = useRef(null);
  const coverInputRef = useRef(null);

  const channelCategories = ['twitter', 'youtube', 'twitch', 'github', 'reddit', 'vimeo'];
  const searchParams = useSearchParams();
  const channelId = searchParams.get('channel');
  const [currentDomain, setCurrentDomain] = useState('');
  const t = useTranslations();
  const router = useRouter();

  useEffect(() => {
    fetchChannelList();
    setCurrentDomain(window.location.origin)
  }, []);

  async function fetchChannelList() {
    const res = await apiRequest(`contribution_page`);
    setChannelList(res);
    if (res.length > 0) {
      await fetchChannelData({value: channelId || res[0].id});
    } else {
      setNoChannels(true);
      setIsLoading(false);
    }
  }

  async function fetchChannelData({value}) {
    setIsLoading(true);
    const channelData = await apiRequest(`contribution_page/${value}`);
    setChannel(channelData);
    await updateChannelAttributes(channelData);
    setIsLoading(false);
  }

  async function updateChannelAttributes(channelData) {
    const bannerDetails = channelData.site_banner.read_only_react_property;
    setTitle(bannerDetails.title);
    setPublicIdentifier(channelData.public_identifier);
    setDescription(bannerDetails.description);
    setSocialLinks(bannerDetails.socialLinks);
    setLogoUrl(bannerDetails.logoUrl);
    setCoverUrl(bannerDetails.backgroundUrl);
  }

  function channelType(channelObj) {
    return channelObj.details_type.split('ChannelDetails').join('').toLowerCase();
  }

  function channelDisplay(type) {
    return t(`contribution_pages.channel_names.${type}`);
  }

  function channelIconType(channelType) {
    if (channelType === 'site') {
      return <Icon className='color-interactive inline-block align-top' name='globe' forceColor={true}/>;
    } else if (channelType === 'twitter') {
      return <Icon className='inline-block align-top' name='social-x' forceColor={true} />;
    } else {
      return <Icon className='inline-block align-top' name={`social-${channelType}`} forceColor={true} />;
    }
  }

  async function updateAttribute(body) {
    setToastMessage(t('contribution_pages.saving_toast'))
    const res = await apiRequest(`contribution_page/${channel.id}`, 'PATCH', body);
    setChannel(res);
    await updateChannelAttributes(res);
  }

  async function saveTitle(e) {
    await updateAttribute({ title: e.value });
  }

  async function saveDescription(e) {
    if (e.target.value !== description) {
      await updateAttribute({ description: e.target.value });
    }
  }

  async function updateSocial(category, value) {
    const patchData = {};
    patchData[category] = value;
    await updateAttribute({ socialLinks: patchData });
  }

  async function readData(file) {
    let reader = new FileReader();
    reader.readAsDataURL(file.files[0]);
    return new Promise(
      resolve =>
        (reader.onloadend = function() {
          resolve(reader.result);
        })
    );
  }

  async function addLogo(e) {
    const logoData = await readData(event.target)
    await updateAttribute({logo: logoData});
  }

  const triggerLogoInput = () => {
    logoInputRef.current.click();  // Trigger the hidden file input on mobile
  };

  async function addCover(e) {
    const coverData = await readData(event.target)
    await updateAttribute({cover: coverData});
  }

  const triggerCoverInput = () => {
    coverInputRef.current.click();
  };

  async function deleteImage(type) {
    if((type === 'logo' && logoUrl.length) || (type === 'cover' && coverUrl.length)) {
      setToastMessage(t('contribution_pages.saving_toast'))
      const res = await apiRequest(`contribution_page/${channel.id}/destroy_attachment`, 'DELETE', {[type]: true});
      setChannel(res)
      await updateChannelAttributes(res);
    }
  }

  function renderSocialLinks(category, socialLinks) {
    const options = channelList.filter((c) => channelType(c) === category);
    const noOptions = options.length === 0;
    
    return (
      <div className={`${styles['social-link-wrapper']}`} key={category}>
        <div>
          <div className='small-semibold pl-0.5 inline'>{channelDisplay(category)}</div>
          {noOptions && (
            <Link className='small-semibold pl-0.5 inline' href={`/publishers/home?addChannelModal=true`}>{t('contribution_pages.add_account')}</Link>
          )}
        </div>
        <Dropdown
          placeholder={noOptions ? t('contribution_pages.add_account_msg', { social: channelDisplay(category) }) : t('contribution_pages.select_account')}
          disabled={noOptions}
          value={socialLinks[category] || undefined}
          onChange={({value}) => updateSocial(category, value)}
          className='w-full mt-0.5'
          size='normal'
        >
          <div slot='left-icon' className={`${noOptions ? styles['social-link-icon'] : ''}`}>
            {channelIconType(category, !(noOptions || !socialLinks[category]))}
          </div>
          <div slot='value'>
            {socialLinks[category] && socialLinks[category].replace('https://','') || ''}
          </div>
          {options.map((opt) => {
            return(
              <leo-option key={opt.id} value={opt.details.url}>
                <div className='py-1'>{opt.details.url.replace('https://','')}</div>
              </leo-option>
            )
          })}
          {socialLinks[category] && (
            <leo-option key='clear' value=''>
              <div className='py-1'>{t('contribution_pages.clear_social')}</div>
            </leo-option>
          )}
          {/* When there are no options, nala dropdowns are about 4 pixels shorter, which looks weird */}
          {noOptions && (
            <leo-option key='placeholder' value=''></leo-option>
          )}
        </Dropdown>
      </div>
    )
  }

  if (isLoading) {
    return (
      <main className='main transition-colors'>
        <Container>
          <div className='mx-auto max-w-screen-lg'>
            <Card>
              <div className="flex basis-full grow items-center justify-center">
                <ProgressRing />
              </div>
            </Card>
          </div>
        </Container>
      </main>
    );
  } else if (noChannels) {
    return (
      <main className='main transition-colors'>
        <Container>
          <div className='mx-auto max-w-screen-lg'>
            <EmptyChannelCard addChannel={() => router.push('/publishers/home?addChannelModal=true')}/>
          </div>
        </Container>
      </main>
    );
  } else {
    return (
      <main className='main transition-colors'>
        <Container>
          <div className='mx-auto max-w-screen-lg'>
            <Card>
              <div className='headings-display-2 py-4'>
                {t('contribution_pages.page_header')}
              </div>

              <Dropdown
                size='normal'
                value={channel.id}
                className='w-full md:w-1/2 pb-5'
                onChange={fetchChannelData}
              >
                <div slot="left-icon">
                  {channelIconType(channelType(channel))}
                </div>
                <div slot="value">
                  {channel.details.publication_title}
                </div>
                {channelList.map(function (channelName) {
                  return (
                    <leo-option
                      className='py-0'
                      key={channelName.id}
                      value={channelName.id}
                    >
                      {channelIconType(channelType(channelName))}
                      <div className='px-1 inline-block align-top'>{channelName.details.publication_title}</div>
                    </leo-option>
                  );
                })}
              </Dropdown>

              <h2 className='pb-2'>{t('contribution_pages.channel_header')}</h2>
              <div className='small-semibold pl-0.5 pb-0.5'>{t('contribution_pages.sharable_url')}</div>
              <Input
                size='normal'
                value={`${currentDomain}/c/${publicIdentifier}`}
                className='w-full md:w-1/2 inline-block pb-3'
                disabled={true}
              />

              <div className='small-semibold pl-0.5 pb-0.5'>{t('contribution_pages.avatar_cover_image')}</div>
              <div className='hidden md:block relative mb-3'>
                <div style={{ '--cover-url': `url('${coverUrl}')` }} className={`${styles['cover-container']}`}></div>
                <div className={`${styles['cover-edit-container']}`}>
                  <label htmlFor='cover-upload' className={`${styles['logo-upload-btn']}`}>
                    <Icon name='camera' />
                  </label>
                  <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp"  id='cover-upload' onChange={addCover}/>
                  <div className={`ml-1 ${styles['logo-upload-btn']}`} onClick={()=> deleteImage('cover')}>
                    <Icon name='close' />
                  </div>
                </div>
                <div className={`${styles['logo-upload-container']}`}>
                  <div style={{ '--logo-url': `url('${logoUrl}')` }} className={`${styles['logo-container']}`}></div>
                  <div className={`${styles['logo-edit-container']}`}>
                    <label htmlFor='logo-upload' className={`${styles['logo-upload-btn']}`}>
                      <Icon name='camera' />
                    </label>
                    <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp"  id='logo-upload' onChange={addLogo}/>
                    <div className={`ml-1 ${styles['logo-upload-btn']}`} onClick={()=> deleteImage('logo')}>
                      <Icon name='close' />
                    </div>
                  </div>
                </div>
              </div>
              
              <div className='small-semibold pl-0.5 pb-0.5'>{t('contribution_pages.channel_name')}</div>
              <Input
                value={title}
                onChange={saveTitle}
                className='w-full md:w-1/2 inline-block'
              />
              <div className='small-semibold pb-0.5 pl-0.5 mt-3'>{t('contribution_pages.bio')}</div>
              <div className='flex mb-5'>
                <textarea
                  name='description'
                  onBlur={saveDescription}
                  className={`${styles['bio-textarea']}`}
                  defaultValue={description}
                  rows='5'
                />
              </div>

              <div className="md:hidden">
                <div className='small-semibold pl-0.5 mt-3 pb-0.5'>{t('contribution_pages.profile')}</div>
                <div className='flex justify-normal justify-items-start items-center'>
                  <div style={{ '--logo-url': `url('${logoUrl}')` }} className={`${styles['logo-container-mobile']}`}></div>
                  <Button kind='outline' className='grow-0' onClick={triggerLogoInput}>{t('shared.change')}</Button>
                  <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp" ref={logoInputRef} onChange={addLogo}/>
                  <Button kind='plain-faint' className={`ml-1 grow-0`} onClick={()=> deleteImage('logo')}>
                    {t('shared.remove')}
                  </Button>
                </div>
                <div className='small-semibold pl-0.5 mt-3 pb-0.5'>{t('contribution_pages.cover')}</div>
                <div style={{ '--cover-url': `url('${coverUrl}')` }} className={`${styles['cover-container-mobile']}`}></div>
                <Button onClick={triggerCoverInput} kind='outline'>{t('shared.change')}</Button>
                <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp" ref={coverInputRef} onChange={addCover}/>
                <Button kind='plain-faint' className={`ml-1`} onClick={()=> deleteImage('cover')}>
                  {t('shared.remove')}
                </Button>
              </div>

              <h2 className='pt-5 mb-3'>{t('contribution_pages.show_social_links')}</h2>
              <div className='grid grid-cols-1 lg:grid-cols-2 gap-2 items-start'>
                {channelCategories.map((category) => renderSocialLinks(category, socialLinks))}
              </div>
              <div className='py-3 color-tertiary'>
                {t('contribution_pages.social_link_note')}
              </div>
              <Hr/>
              <Button className='px-3 pt-5' onClick={()=> setPreviewModalOpen(true)}>{t('contribution_pages.preview_btn')}</Button>
            </Card>
          </div>
        </Container>
        {toastMessage && (
          <Toast 
            message={toastMessage} 
            onClose={() => setToastMessage('')}
          />
        )}
        <Dialog
          isOpen={previewModalOpen}
          onClose={() => (setPreviewModalOpen(false))}
          showClose={true}
          className={`${styles['preview-modal']}`}
        >
          <Preview channel={channel} isOpen={previewModalOpen} />
        </Dialog>
      </main>
    );
  }
}
