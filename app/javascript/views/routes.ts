/* tslint:disable:object-literal-sort-keys */
export default {
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
  }
};
