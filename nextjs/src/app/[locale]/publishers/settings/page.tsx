'use client';

import Button from '@brave/leo/react/button';
import Checkbox from '@brave/leo/react/checkbox';
import Dialog from '@brave/leo/react/dialog';
import Toggle from '@brave/leo/react/toggle';
import Head from 'next/head';
import { useContext, useState } from 'react';
import * as React from 'react';

import { apiRequest } from '@/lib/api';
import UserContext from '@/lib/context/UserContext';
import { UserType } from '@/lib/propTypes';

import Card from '@/components/Card';

export default function SettingsPage() {
  const { user, updateUser } = useContext(UserContext);
  const [isModalOpen, setModalIsOpen] = useState(false);
  const [settings, setSettings] = useState<Partial<UserType>>(user);
  const [isEditMode, setIsEditMode] = useState(false);

  function updateAccountSettings() {
    apiRequest('publishers/me', settings, 'POST');
    updateUser(settings);
  }

  function deleteAccount() {
    apiRequest('publishers/me', null, 'DELETE');
  }

  function handleToggleChange(e: CustomEvent, name: string) {
    setSettings({ ...settings, [name]: e.detail.checked });
    updateAccountSettings();
  }

  function handleInputChange(e: React.ChangeEvent<HTMLInputElement>) {
    setSettings({ ...settings, [e.target.name]: e.target.value });
  }

  return (
    <main className='main'>
      <Head>
        <title>Settings</title>
      </Head>
      <section className='content-width'>
        <Card className='mb-3'>
          <h2 className='mb-2'>Account Settings</h2>
          <div className='flex items-center justify-between'>
            <p>Keep my login active for 30 days</p>
            <Toggle
              size='small'
              checked={settings.thirty_day_login}
              onChange={(e) => handleToggleChange(e, 'thirty_day_login')}
            />
          </div>
        </Card>

        <Card className='mb-3'>
          <div className='mb-2 flex items-center justify-between'>
            <h2>Contact</h2>
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
                    Save
                  </Button>
                  <Button
                    kind='plain'
                    size='large'
                    onClick={() => setIsEditMode(false)}
                  >
                    Cancel
                  </Button>
                </div>
              ) : (
                <Button
                  kind='plain'
                  size='large'
                  onClick={() => setIsEditMode(true)}
                >
                  Edit Contact
                </Button>
              )}
            </div>
          </div>

          <div>
            <div>
              <label className='font-semibold'>Name</label>
              <div className='mb-2'>
                {isEditMode ? (
                  <input
                    value={settings.name}
                    onChange={handleInputChange}
                    name='name'
                  />
                ) : (
                  user.name
                )}
              </div>
            </div>
            <div>
              <label className='font-semibold'>Email</label>
              <div>
                {isEditMode ? (
                  <input
                    value={settings.email}
                    onChange={handleInputChange}
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
          <h2 className='mb-2'>Email Settings</h2>
          <div>
            <Checkbox
              checked={settings.subscribed_to_marketing_emails}
              onChange={(e) =>
                handleToggleChange(e, 'subscribed_to_marketing_emails')
              }
            >
              By checking here, I consent to be informed of newfeatures and
              promotions via email
            </Checkbox>
          </div>
        </Card>

        <Card className='mb-3'>
          <h2 className='mb-2'>Account Deletion</h2>
          <div>
            Your channels and all accounts related information will be
            permanently deleted from our database as well as from connected
            providers. This cannot be undone.
          </div>
          <Button
            className='mt-4'
            kind='outline'
            onClick={() => setModalIsOpen(!isModalOpen)}
          >
            Delete My Account
          </Button>
        </Card>
        <Dialog isOpen={isModalOpen}>
          <div slot='title'>Are you sure you want to delete your account?</div>
          <div>
            Your Brave Creators account and information will be permanently
            deleted from our database. This action cannot be undone.
          </div>
          <div slot='actions'>
            <Button onClick={() => setModalIsOpen(false)}>
              No, keep my account active
            </Button>
            <Button kind='outline' onClick={deleteAccount}>
              Yes, I'm certain
            </Button>
          </div>
        </Dialog>
      </section>
    </main>
  );
}
