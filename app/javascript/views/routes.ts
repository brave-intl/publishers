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
    promo_registrations: {
      show: {
        path: "/publishers/promo_registrations/for_referral_code?referral_code={referral_code}"
      },
      overview: {
        path: "/publishers/promo_registrations/overview?publisher_id={id}"
      }
    },
    gemini: {
      connect: "/publishers/gemini_connection/connect",
      show: "/publishers/geini_connection",
      destroy: "/publishers/gemini_connection"
    },
    stripe: {
      connect: "/publishers/stripe_connection/connect",
      show: "/publishers/stripe_connection",
      destroy: "/publishers/stripe_connection"
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
      connect: "/publishers/connect_uphold",
      confirm_default_currency: "/publishers/confirm_default_currency",
      disconnect: "/publishers/disconnect_uphold",
      status: "/publishers/uphold_status",
    },
    wallet: {
      path: "/publishers/wallet"
    },
  }
};
