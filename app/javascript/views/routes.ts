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
    connections: {
      currency: "/connections/currency"
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
      connect: "/connections/gemini_connection",
      show: "/connections/gemini_connection",
      destroy: "/connections/gemini_connection"
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
      connect: "/connections/uphold_connection",
      confirm_default_currency: "/connections/confirm_default_currency",
      disconnect: "/connections/uphold_connection",
      status: "/connections/uphold_connection/uphold_status",
    },
    wallet: {
      path: "/publishers/wallet",
      latest: "/publishers/wallet/latest"
    },
  }
};
