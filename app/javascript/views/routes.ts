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
  payments: {
    path: "/partners/payments",
    invoices: {
      path: "/partners/payments/invoices",
      show: {
        path: "/partners/payments/invoices/{id}",
        invoice_files: {
          path: "/partners/payments/invoices/{id}/invoice_files"
        }
      }
    },
    reports: {
      path: "/partners/payments/reports"
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
    }
  }
};
