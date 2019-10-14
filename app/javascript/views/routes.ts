/* tslint:disable:object-literal-sort-keys */
export default {
  admin: {
    promo_registrations: {
      show: {
        path: "/publishers/{publisher_id}/promo_registrations/for_referral_code?referral_code={referral_code}"
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
        path: "{id}/promo_registrations/for_referral_code?referral_code={referral_code}"
      },
      groups: {
        path: "{id}/promo_registrations/groups"
      }
    }
  }
};
