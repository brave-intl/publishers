'use client';

import Input from '@brave/leo/react/input';
import { useEffect, useState } from 'react';

import { apiRequest } from '@/lib/api';

import Card from '@/components/Card';
import Container from '@/components/Container';

export default function PublicChannelPageContainer() {

  async function fetchChannelData() {
    
  }

  useEffect(() => {
    fetchChannelData();
  }, []);

  return (
    <div className='max-w-screen-md'>
      test
    </div>
  );
}
