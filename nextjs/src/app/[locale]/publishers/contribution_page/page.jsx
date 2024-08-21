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
import { useSearchParams } from 'next/navigation'
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';
import Toast from '@/components/Toast';
import Preview from './preview/preview';
import styles from '@/styles/ContributionBanner.module.css';

export default function ContributionPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [channel, setChannel] = useState({});
  const [channelList, setChannelList] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [socialLinks, setSocialLinks] = useState({});
  const [logoUrl, setLogoUrl] = useState('');
  const [coverUrl, setCoverUrl] = useState('');
  const [toastMessage, setToastMessage] = useState('');
  const [previewModalOpen, setPreviewModalOpen] = useState(false);

  const channelCategories = ['twitter', 'youtube', 'twitch', 'github', 'reddit', 'vimeo']
  const searchParams = useSearchParams();
  const channelId = searchParams.get('channel')
  const t = useTranslations();

  useEffect(() => {
    fetchChannelList();
  }, []);

  async function fetchChannelList() {
    const res = await apiRequest(`contribution_page`);
    setChannelList(res);
    await fetchChannelData({value: channelId || res[0].id});
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
    setDescription(bannerDetails.description);
    setSocialLinks(bannerDetails.socialLinks);
    setLogoUrl(bannerDetails.logoUrl);
    setCoverUrl(bannerDetails.coverUrl);
  }

  function channelType(channelObj) {
    return channelObj.details_type.split('ChannelDetails').join('').toLowerCase();
  }

  function channelDisplay(type) {
    return t(`contribution_pages.channel_names.${type}`);
  }

  function channelIconType(channelType, color = true) {
    if (channelType === 'site') {
      return <Icon className='color-interactive inline-block align-top' name='globe' forceColor={color}/>;
    } else if (channelType === 'twitter') {
      return <Icon className='inline-block align-top' name='social-x' forceColor={color} />;
    } else {
      return <Icon className='inline-block align-top' name={`social-${channelType}`} forceColor={color} />;
    }
  }

  async function updateAttribute(body) {
    setToastMessage(t('contribution_pages.saving_toast'))
    const res = await apiRequest(`contribution_page/${channel.id}`, 'PATCH', body);
    console.log(res)
    setChannel(res);
    await updateChannelAttributes(res);
  }

  async function saveTitle(e) {
    await updateAttribute({ title: e.value });
  }

  async function saveDescription(e) {
    await updateAttribute({ description: e.target.value });
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

  async function addCover(e) {
    const coverData = await readData(event.target)
    await updateAttribute({cover: coverData});
  }

  async function deleteImage(type) {
    const res  = await apiRequest(`contribution_page/${channel.id}/destroy_attachment`, 'DELETE', {[type]: true});
    setChannel(res)
    await updateChannelAttributes(res);
  }

  function renderSocialLinks(category, socialLinks) {
    const options = channelList.filter((c) => channelType(c) === category);
    const noOptions = options.length === 0;
    
    return (
      <div className={`${styles['social-link-wrapper']}`}>
        <div className='small-semibold pl-0.5 inline'>{channelDisplay(category)}</div>
        {noOptions && (
          <Link className='small-semibold pl-0.5 inline' href={`/publishers/home?addChannelModal=true`}>{t('contribution_pages.add_account')}</Link>
        )}
        <Dropdown
          key={category}
          placeholder={noOptions ? t('contribution_pages.add_account_msg', { social: channelDisplay(category) }) : t('contribution_pages.select_account')}
          disabled={noOptions}
          value={socialLinks[category] || undefined}
          onChange={({value}) => updateSocial(category, value)}
          className='w-full'
        >
          <div slot='left-icon'>
            {channelIconType(category, !(noOptions || !socialLinks[category]))}
          </div>
          <div slot='value'>
            {socialLinks[category].replace('https://','')}
          </div>
          {options.map((opt) => {
            return(
              <leo-option key={opt.id} value={opt.details.url}>
                <div>{opt.details.url.replace('https://','')}</div>
              </leo-option>
            )
          })}
          <leo-option key={'clear'} value={''}>
            <div>{t('contribution_pages.clear_social')}</div>
          </leo-option>
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
    )
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
             {/* <Dropdown
                size='normal'
                value={channel.details.public_name}
                className='w-full md:w-1/2'
                
              >
                <div slot="label">
                  {t('contribution_pages.sharable_url')}
                </div>
              </Dropdown>*/}

              <div className='small-semibold pl-0.5 pb-0.5'>{t('contribution_pages.avatar_cover_image')}</div>
              <div className='hidden md:block relative mb-3'>
                <div style={{ '--cover-url': `url('${coverUrl}')` }} className={`${styles['cover-container']}`}></div>
                <div className={`${styles['cover-edit-container']}`}>
                  <label htmlFor='cover-upload' className={`${styles['logo-upload-btn']}`}>
                    <Icon name='camera' />
                  </label>
                  <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp"  id='cover-upload' onChange={addCover}/>
                  <Button fab className={`ml-1 ${styles['logo-upload-btn']}`} onClick={()=> deleteImage('cover')}>
                    <Icon name='close' />
                  </Button>
                </div>
                <div className={`${styles['logo-upload-container']}`}>
                  <div style={{ '--logo-url': `url('${logoUrl}')` }} className={`${styles['logo-container']}`}></div>
                  <div className={`${styles['logo-edit-container']}`}>
                    <label htmlFor='logo-upload' className={`${styles['logo-upload-btn']}`}>
                      <Icon name='camera' />
                    </label>
                    <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp"  id='logo-upload' onChange={addLogo}/>
                    <Button fab className={`ml-1 ${styles['logo-upload-btn']}`} onClick={()=> deleteImage('logo')}>
                      <Icon name='close' />
                    </Button>
                  </div>
                </div>
              </div>
              
              <div className='small-semibold pl-0.5'>{t('contribution_pages.channel_name')}</div>
              <Input
                value={title}
                onChange={saveTitle}
              />
              <div className='small-semibold pl-0.5 mt-3'>{t('contribution_pages.bio')}</div>
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
                <div className='flex justify-start items-center'>
                  <div style={{ '--logo-url': `url('${logoUrl}')` }} className={`${styles['logo-container-mobile']}`}></div>
                  <label htmlFor='logo-upload' className={``}>
                    <Button kind='outline'>{t('shared.change')}</Button>
                  </label>
                  <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp"  id='logo-upload' onChange={addLogo}/>
                  <Button kind='plain-faint' className={`ml-1`} onClick={()=> deleteImage('logo')}>
                    {t('shared.remove')}
                  </Button>
                </div>
                <div className='small-semibold pl-0.5 mt-3 pb-0.5'>{t('contribution_pages.cover')}</div>
                <div style={{ '--cover-url': `url('${coverUrl}')` }} className={`${styles['cover-container-mobile']}`}></div>
                <label htmlFor='cover-upload' className={``}>
                 <Button kind='outline'>{t('shared.change')}</Button>
                </label>
                <input className='hidden' type="file" accept="image/png, image/jpeg, image/webp"  id='cover-upload' onChange={addCover}/>
                <Button kind='plain-faint' className={`ml-1`} onClick={()=> deleteImage('cover')}>
                  {t('shared.remove')}
                </Button>
              </div>

              <h2 className='pt-5 mb-3'>{t('contribution_pages.show_social_links')}</h2>
              <div className='grid grid-cols-1 lg:grid-cols-2 gap-2'>
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
          <Preview channel={channel}/>
        </Dialog>
      </main>
    );
  }
}
