'use client';

import Icon from '@brave/leo/react/icon';
import styles from '@/styles/ChannelCard.module.css';

export default function CryptoWalletOption({
  value,
  innerProps,
  label,
  selectProps,
}) {
  const deleteAddress = selectProps.deleteAddress;
  const formatCryptoAddress = selectProps.formatCryptoAddress;

  function handleDelete(e) {
    e.stopPropagation();
    deleteAddress(value);
    close();
  }

  if (value.hasOwnProperty('newAddress')) {
    return (
      <div {...innerProps} className={styles['new-wallet-button']}>
        <span>{label}</span>
      </div>
    );
  } else if (value.hasOwnProperty('clearAddress')) {
    if (value.deletedAddress) {
      return (
        <div {...innerProps} className={styles['new-wallet-button']}>
          <span>{label}</span>
        </div>
      );
    } else {
      return null;
    }
  } else {
    return (
      <div {...innerProps} className={styles['address-option']}>
        <span>
          <span>{formatCryptoAddress(value.address)}</span>
        </span>
        <span onClick={handleDelete}>
          <Icon name='trash' />
        </span>
      </div>
    );
  }
}
