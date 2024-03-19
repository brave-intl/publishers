'use client';

import Button from '@brave/leo/react/button';
import Dialog from '@brave/leo/react/dialog';
import ProgressRing from '@brave/leo/react/progressRing';
import * as moment from 'moment';
import { useTranslations } from 'next-intl';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';
import CryptoAddressProvider from '@/components/CryptoAddressProvider';

import AddChannelModal from './channels/AddChannelModal';
import ChannelCard from './channels/ChannelCard';
import CustodianServiceWidget from './custodianServices/CustodianServiceWidget';

export default function HomePage() {
  const [isLoading, setIsLoading] = useState(true);
  const [lastDeposit, setLastDeposit] = useState(0);
  const [lastDepositDate, setLastDepositDate] = useState('');
  const [nextDepositDate, setNextDepositDate] = useState('');
  const [channels, setChannels] = useState([]);
  const [publisherPayable, setPublisherPayable] = useState(false);
  const [walletData, setWalletData] = useState({});
  const [isAddChannelModalOpen, setIsAddChannelModalOpen] = useState(false);
  const t = useTranslations();

  useEffect(() => {
    fetchDashboard();
  }, []);

  async function fetchDashboard() {
    const res = await apiRequest(`/home/dashboard`);
    const wallet = res.wallet_data;
    setLastDeposit(
      Math.round(wallet.wallet.last_settlement_balance.amount_bat) || 0,
    );
    setNextDepositDate(wallet.next_deposit_date);
    setLastDepositDate(
      moment
        .unix(wallet.wallet.last_settlement_balance.timestamp)
        .format('MMM D, YYYY - h:mm a'),
    );
    setChannels(res.channels);
    setWalletData(wallet);
    setPublisherPayable(
      res.publisher.payable &&
        (wallet.bitflyer_connection ||
          wallet.uphold_connection ||
          wallet.gemini_connection),
    );
    setIsLoading(false);
  }

  if (isLoading) {
    return <ProgressRing />;
  } else {
    return (
      <main className='main transition-colors'>
        <Container>
          <div className='mx-auto max-w-screen-lg'>
            <h1 className='mb-2'>{t('Home.headings.account_details')}</h1>
            <Card className='flex items-top'>
              <section className='inline-block w-full md:w-1/2'>
                <h3>{t('Home.account.monthly_payouts')}</h3>
                <section className='grid grid-cols-2'>
                  <div>{t('Home.account.last_deposit')}</div>
                  <div>
                    <strong>{lastDeposit} BAT</strong>
                  </div>
                  <div>{t('Home.account.last_deposit_date')}</div>
                  <div>{lastDepositDate}</div>
                  <div>{t('Home.account.next_deposit_date')}</div>
                  <div>{nextDepositDate}</div>
                </section>
              </section>
              <section className='inline-block w-full md:w-1/2'>
                <h3>{t('Home.account.custodial_accounts')}</h3>
                <CustodianServiceWidget walletData={walletData} />
              </section>
            </Card>
            <h1 className='mb-2 mt-3'>{t('Home.headings.channels')}</h1>
            <CryptoAddressProvider>
              <section className='grid grid-cols-2 gap-4'>
                {channels.map(function (channel) {
                  return (
                    <ChannelCard
                      key={channel.id}
                      channel={channel}
                      publisherPayable={publisherPayable}
                    />
                  );
                })}
              </section>
            </CryptoAddressProvider>
            <Button onClick={() => setIsAddChannelModalOpen(true)}>
              {t('Home.channels.add_channel')}
            </Button>
          </div>
        </Container>
        <Dialog
          isOpen={isAddChannelModalOpen}
          onClose={() => setIsAddChannelModalOpen(false)}
        >
          <AddChannelModal />
        </Dialog>
      </main>
    );
  }
}
