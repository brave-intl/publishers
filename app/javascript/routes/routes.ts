export default {
  admin: {
    userNavbar: {
      // TODO: These routes aren't RESTful and should be fixed
      channels: {
        path: "/admin/channels/{id}"
      },
      dashboard: {
        path: "/admin/publishers/{id}"
      },
      payments: {
        path: "/admin/payments/{id}"
      },
      referrals: {
        path: "/admin/publishers/{id}/referrals"
      }
    }
  },
  navbar: {
    channels: {
      path: "/partners/channels"
    },
    dashboard: {
      path: "/publishers/home"
    },
    help: {
      path: "https://support.brave.com/hc/en-us/"
    },
    logOut: {
      path: "/publishers/log_out"
    },
    payments: {
      path: "/partners/payments"
    },
    referrals: {
      path: "/partners/referrals"
    },
    security: {
      path: "/publishers/two_factor_registrations"
    }
  }
};
