'use client';

import Button from '@brave/leo/react/button';
import Dialog from '@brave/leo/react/dialog';
import ProgressRing from '@brave/leo/react/progressRing';
import * as moment from 'moment';
import { useSearchParams } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';
import CryptoAddressProvider from '@/components/CryptoAddressProvider';

import AddChannelModal from './channels/AddChannelModal';
import ChannelCard from './channels/ChannelCard';
import EmptyChannelCard from './channels/EmptyChannelCard';
import CustodianServiceWidget from './custodianServices/CustodianServiceWidget';

export default function HomePage() {
  const [isLoading, setIsLoading] = useState(true);
  const [lastDeposit, setLastDeposit] = useState(0);
  const [lastDepositDate, setLastDepositDate] = useState('');
  const [nextDepositDate, setNextDepositDate] = useState('');
  const [channels, setChannels] = useState([]);
  const [walletData, setWalletData] = useState({});
  const [publisherId, setPublisherId] = useState('');
  const [isAddChannelModalOpen, setIsAddChannelModalOpen] = useState(false);
  const searchParams = useSearchParams();
  const startWithModalOpen = searchParams.get('addChannelModal');
  const t = useTranslations();

  useEffect(() => {
    fetchDashboard();
  }, []);

  async function fetchDashboard() {
    const res = await apiRequest(`/home/dashboard`);
    const wallet = res.wallet_data;
    if (wallet.wallet && wallet.wallet.last_settlement_balance) {
      setLastDeposit(
        Math.round(wallet.wallet.last_settlement_balance.amount_bat) || 0,
      );

      wallet.wallet.last_settlement_balance.timestamp
        ? setLastDepositDate(
            moment
              .unix(wallet.wallet.last_settlement_balance.timestamp)
              .format('MMM D, YYYY - h:mm a'),
          )
        : setLastDepositDate('--');
    } else {
      setLastDeposit(0);
      setLastDepositDate('--');
    }

    setPublisherId(res.publisher.id);

    setWalletData(wallet);
    setNextDepositDate(wallet.next_deposit_date);
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
            <h1 className='mb-3'>{t('Home.headings.account_details')}</h1>
            <Card className='lg:items-top lg:flex'>
              <section className='inline-block w-full lg:w-1/2'>
                <h3 className='pb-3'>{t('Home.account.monthly_payouts')}</h3>
                <section className='grid sm:grid-cols-2'>
                  <div className='pb-0 sm:pb-2'>
                    {t('Home.account.last_deposit')}
                  </div>
                  <div className='pb-2 sm:pb-0'>
                    <strong>{lastDeposit} BAT</strong>
                  </div>
                  <div className='pb-0 sm:pb-2'>
                    {t('Home.account.last_deposit_date')}
                  </div>
                  <div className='pb-2 sm:pb-0'>{lastDepositDate}</div>
                  <div className='pb-0 sm:pb-2'>
                    {t('Home.account.next_deposit_date')}
                  </div>
                  <div className='pb-2 sm:pb-0'>{nextDepositDate}</div>
                </section>
              </section>
              <section className='inline-block w-full pt-2 lg:w-1/2 lg:pt-0'>
                <h3 className='pb-3'>{t('Home.account.custodial_accounts')}</h3>
                <CustodianServiceWidget walletData={walletData} />
              </section>
            </Card>
            <h1 className='mb-3 mt-3'>{t('Home.headings.channels')}</h1>
            {channels.length ? (
              <>
                <CryptoAddressProvider>
                  <section className='grid grid-cols-1 gap-4 lg:grid-cols-2'>
                    {channels.map(function (channel) {
                      return (
                        <ChannelCard
                          key={channel.id}
                          channel={channel}
                          publisherId={publisherId}
                          onChannelDelete={onChannelDelete}
                        />
                      );
                    })}
                  </section>
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
