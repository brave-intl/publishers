'use client';

import Head from 'next/head';
import * as React from 'react';

import styles from './styles.module.css';

export default function HomePage() {
  return (
    <main className={styles.main}>
      <Head>
        <title>Settings</title>
      </Head>
      <section>
        <div>
          <h1>Settings Title</h1>
          <p>Keep my login active for 30 days</p>
        </div>
      </section>
    </main>
  );
}
