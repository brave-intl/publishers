'use client';

import Button from '@brave/leo/react/button';
import Collapse from '@brave/leo/react/collapse';
import Dialog from '@brave/leo/react/dialog';
import ProgressRing from '@brave/leo/react/progressRing';
import Icon from '@brave/leo/react/icon';
import * as moment from 'moment';
import { useSearchParams } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';
import styles from '@/styles/Dashboard.module.css';

import addAccounts from "~/images/add_accounts.png";
import addPayment from "~/images/add_payment.png";
import receiveContributions from "~/images/receive_contributions.png";

import Card from '@/components/Card';
import Container from '@/components/Container';
import CryptoAddressProvider from '@/lib/context/CryptoAddressContext';
import ChannelCardProvider from '@/lib/context/ChannelCardContext';
import CustodianConnectionProvider from '@/lib/context/CustodianConnectionContext';

import AddChannelModal from './channels/AddChannelModal';
import ChannelCard from './channels/ChannelCard';
import EmptyChannelCard from './channels/EmptyChannelCard';

export default function HomePage() {
  const [isLoading, setIsLoading] = useState(true);
  const [channels, setChannels] = useState([]);
  const [publisherId, setPublisherId] = useState('');
  const [isAddChannelModalOpen, setIsAddChannelModalOpen] = useState(false);
  const [isCollapseOpen, setIsCollapseOpen] = useState(true);
  const searchParams = useSearchParams();
  const startWithModalOpen = searchParams.get('addChannelModal');
  const t = useTranslations();
  const [custodianData, setCustodianData] = useState({});

  useEffect(() => {
    fetchDashboard();
  }, []);

  async function fetchDashboard() {
    const res = await apiRequest(`/home/dashboard`);
    setCustodianData(res.wallet_data);
    setPublisherId(res.publisher.id);
    setChannels(res.channels);
    setIsLoading(false);
    if (startWithModalOpen) {
      setIsAddChannelModalOpen(true);
    }
  }

  function onChannelDelete(channelId) {
    const newChannels = channels.filter((c) => c.id !== channelId);
    setChannels(newChannels);
  }

  if (isLoading) {
    return (
      <div className='flex grow basis-full items-center justify-center'>
        <ProgressRing />
      </div>
    );
  } else {
    return (
      <main className='main transition-colors'>
        <Container>
          <div className='mx-auto max-w-screen-lg'>
            <Collapse isOpen={isCollapseOpen} onToggle={()=>{setIsCollapseOpen(!isCollapseOpen)}}>
              <div slot='title'><h4>{t('Home.headings.how_to_receive')}</h4></div>
              <div className="grid grid-cols-1 gap-1 lg:grid-cols-3 lg:gap-2">
                <div className={`relative ${styles['howto-box-orange']}`}>
                  <img className='hidden lg:block' src={addAccounts.src}/>
                  <div className={`${styles['howto-text']}`}>
                    <h4 className='pl-0.5'>{t('Home.headings.add_accounts')}</h4>
                    <p className='pt-1'>{t('Home.headings.add_accounts_text')}</p>
                  </div>
                  <div className={`z-20 hidden lg:flex top-1/2 items-center shadow ${styles['howto-arrow']}`}>
                    <Icon className={`mx-auto ${styles['howto-arrow-icon']}`} name='arrow-right' />
                  </div>
                </div>
                <div className={`z-10 relative ${styles['howto-box-pink']}`}>
                  <img className='hidden lg:block' src={addPayment.src}/>
                  <div className={`${styles['howto-text']}`}>
                    <h4 className='pl-0.5'>{t('Home.headings.add_payments')}</h4>
                    <p className='pt-1'>{t('Home.headings.add_payments_text')}</p>
                  </div>
                  <div className={`hidden lg:flex top-1/2 items-center shadow ${styles['howto-arrow']}`}>
                    <Icon className={`mx-auto ${styles['howto-arrow-icon']}`} name='arrow-right' />
                  </div>
                </div>
                <div className={`${styles['howto-box-purple']}`}>
                  <img src={receiveContributions.src}/>
                  <div className={`${styles['howto-text']}`}>
                    <h4 className='pl-0.5'>{t('Home.headings.receive_contributions')}</h4>
                    <p className='pt-1'>{t('Home.headings.receive_contributions_text')}</p>
                  </div>
                </div>
              </div>
            </Collapse>
            <h1 className='mb-3 mt-3'>{t('Home.headings.channels')}</h1>
            {channels.length ? (
              <>
                <CryptoAddressProvider>
                  <CustodianConnectionProvider>
                    <section className='grid grid-cols-1 gap-4 lg:grid-cols-2'>
                      {channels.map(function (channel) {
                        return (
                          <ChannelCardProvider key={channel.id}>
                            <ChannelCard
                              key={channel.id}
                              channel={channel}
                              publisherId={publisherId}
                              onChannelDelete={onChannelDelete}
                              custodianData={custodianData}
                            />
                            </ChannelCardProvider>
                        );
                      })}
                    </section>
                  </CustodianConnectionProvider>
                </CryptoAddressProvider>
                <Button
                  id='add-channel'
                  className='pt-3'
                  onClick={() => setIsAddChannelModalOpen(true)}
                >
                  {t('Home.channels.add_channel')}
                </Button>
              </>
            ) : (
              <EmptyChannelCard addChannel={setIsAddChannelModalOpen} />
            )}
          </div>
        </Container>
        <Dialog
          isOpen={isAddChannelModalOpen}
          onClose={() => setIsAddChannelModalOpen(false)}
          showClose={true}
        >
          <AddChannelModal />
        </Dialog>
      </main>
    );
  }
}
