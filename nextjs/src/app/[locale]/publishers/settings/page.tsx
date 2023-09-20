'use client';

import Button from '@brave/leo/react/button';
import Checkbox from '@brave/leo/react/checkbox';
import Dialog from '@brave/leo/react/dialog';
import Input from '@brave/leo/react/input';
import Toggle from '@brave/leo/react/toggle';
import Head from 'next/head';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useContext, useState } from 'react';
import * as React from 'react';

import { apiRequest } from '@/lib/api';
import UserContext from '@/lib/context/UserContext';
import { pick } from '@/lib/helper';
import { UserType } from '@/lib/propTypes';

import Card from '@/components/Card';

export default function SettingsPage() {
  const { user, updateUser } = useContext(UserContext);
  const [isModalOpen, setModalIsOpen] = useState(false);
  const [settings, setSettings] = useState<Partial<UserType>>(user);
  const [isEditMode, setIsEditMode] = useState(false);
  const { push } = useRouter();
  const t = useTranslations();

  function updateAccountSettings(newSettings?) {
    apiRequest(
      `publishers/${user.id}`,
      {
        publisher: pick(
          newSettings || settings,
          'email',
          'name',
          'subscribed_to_marketing_emails',
          'thirty_day_login',
        ),
      },
      'PUT',
    );
    updateUser(settings);
  }

  function deleteAccount() {
    apiRequest('publishers', null, 'DELETE');
    push('/');
  }

  function handleToggleChange(e: CustomEvent, name: string) {
    const newSettings = { ...settings, [name]: e.detail.checked };

    setSettings(newSettings);
    updateAccountSettings(newSettings);
  }

  function handleInputChange(e, name) {
    setSettings({ ...settings, [name]: e.detail.value });
  }

  return (
    <main className='main'>
      <Head>
        <title>{t('Settings.title')}</title>
        hello
      </Head>
      <section className='content-width'>
        <Card className='mb-3'>
          <h2 className='mb-2'>{t('Settings.index.header')}</h2>
          <div className='flex items-center justify-between'>
            <p>{t('Settings.index.extended_login.intro')}</p>
            <Toggle
              size='small'
              checked={settings.thirty_day_login}
              onChange={(e) => handleToggleChange(e, 'thirty_day_login')}
            />
          </div>
        </Card>

        <Card className='mb-3'>
          <div className='mb-2 flex items-center justify-between'>
            <h2>{t('Settings.index.contact.heading')}</h2>
            <div>
              {isEditMode ? (
                <div>
                  <Button
                    className='mr-1'
                    onClick={() => {
                      updateAccountSettings();
                      setIsEditMode(false);
                    }}
                    kind='filled'
                  >
                    {t('Settings.buttons.save')}
                  </Button>
                  <Button
                    kind='plain'
                    size='large'
                    onClick={() => setIsEditMode(false)}
                  >
                    {t('Settings.buttons.cancel')}
                  </Button>
                </div>
              ) : (
                <Button
                  kind='plain'
                  size='large'
                  onClick={() => setIsEditMode(true)}
                >
                  {t('Settings.index.contact.edit')}
                </Button>
              )}
            </div>
          </div>

          <div>
            <div>
              <label className='font-semibold'>
                {t('Settings.index.contact.name')}
              </label>
              <div className='mb-2 sm:w-[400px]'>
                {isEditMode ? (
                  <Input
                    value={settings.name}
                    onInput={(e) => handleInputChange(e, 'name')}
                    name='name'
                  />
                ) : (
                  user.name
                )}
              </div>
            </div>
            <div>
              <label className='font-semibold'>
                {t('Settings.index.contact.email')}
              </label>
              <div className='sm:w-[400px]'>
                {isEditMode ? (
                  <Input
                    value={settings.email}
                    onInput={(e) => handleInputChange(e, 'email')}
                    name='email'
                  />
                ) : (
                  user.email
                )}
              </div>
            </div>
          </div>
        </Card>

        <Card className='mb-3'>
          <h2 className='mb-2'>{t('Settings.index.email.heading')}</h2>
          <h4>Notifications</h4>
          <div className='mt-1'>
            <Checkbox
              checked={settings.subscribed_to_marketing_emails}
              onChange={(e) =>
                handleToggleChange(e, 'subscribed_to_marketing_emails')
              }
            >
              {t('Settings.index.email.marketing_label')}
            </Checkbox>
          </div>
        </Card>

        <Card className='mb-3'>
          <h2 className='mb-2'>{t('Settings.index.delete_account.heading')}</h2>
          <div>{t('Settings.index.delete_account.warning')}</div>
          <Button
            className='mt-4'
            kind='outline'
            onClick={() => setModalIsOpen(!isModalOpen)}
          >
            {t('Settings.index.delete_account.button')}
          </Button>
        </Card>
        <Dialog isOpen={isModalOpen}>
          <div slot='title'>
            {t('Settings.index.delete_account.prompt.header')}
          </div>
          <div>{t('Settings.index.delete_account.prompt.warning')}</div>
          <div slot='actions'>
            <Button onClick={() => setModalIsOpen(false)}>
              {t('Settings.index.delete_account.prompt.deny')}
            </Button>
            <Button kind='outline' onClick={deleteAccount}>
              {t('Settings.index.delete_account.prompt.confirm')}
            </Button>
          </div>
        </Dialog>
      </section>
    </main>
  );
}
