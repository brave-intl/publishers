/* tslint:disable:object-literal-sort-keys */
export default {
  admin: {
    promo_registrations: {
      show: {
        path:
          "/publishers/promo_registrations/for_referral_code?referral_code={referral_code}&publisher_id={publisher_id}"
      }
    }
  },
  publishers: {
    bitflyer: {
      connect: "/connection/bitflyer_connection",
      destroy: "/connection/bitflyer_connection"
    },
    promo_registrations: {
      show: {
        path: "/publishers/promo_registrations/for_referral_code?referral_code={referral_code}"
      },
      overview: {
        path: "/publishers/promo_registrations/overview?publisher_id={id}"
      }
    },
    gemini: {
      connect: "/connection/gemini_connection",
      show: "/connection/gemini_connection",
      destroy: "/connection/gemini_connection"
    },
    statements: {
      index: {
        path: "/publishers/statements"
      },
      show: {
        path: "/publishers/statements/{period}"
      },
      rate_card: {
        path: "/publishers/statements/rate_card"
      },
    },
    update: {
      path: "/publishers"
    },
    uphold: {
      connect: "/connection/uphold_connection",
      confirm_default_currency: "/connection/confirm_default_currency",
      disconnect: "/connection/uphold_connection",
      status: "/connection/uphold_connection/uphold_status",
    },
    wallet: {
      path: "/publishers/wallet",
      latest: "/publishers/wallet/latest"
    },
    cryptoAddressForChannels: {
      create: "/channels/{channel_id}/crypto_address_for_channels",
      index: "/channels/{channel_id}/crypto_address_for_channels",
      changeAddress: "/channels/{channel_id}/crypto_address_for_channels/change_address",
      generateNonce: "/channels/{channel_id}/crypto_address_for_channels/generate_nonce"
    },
    cryptoAddresses: {
      index: "/publishers/crypto_addresses",
      delete: "/publishers/crypto_addresses/{id}"
    },
    publicChannelPage: {
      getRatios: "/get_ratios",
    }
  }
};
