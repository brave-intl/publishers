document.addEventListener('DOMContentLoaded', function() {
  var unattachedReferralCodeForm = document.getElementById('unattached-referral-code-form');

  function addListener(id, callback) {
    let element = document.getElementById(id);
    if (element) {
      element.addEventListener('click', callback);
    }
  }

  addListener('assign-to-campaign', () => {
    unattachedReferralCodeForm.action = '/admin/unattached_promo_registrations/assign_campaign';
  });
  addListener('assign-installer-type', () => {
    unattachedReferralCodeForm.action = '/admin/unattached_promo_registrations/assign_installer_type';
    document.getElementsByName("_method")[0].value = 'put';
  });
  addListener('download-referral-reports', () => {
    unattachedReferralCodeForm.action = '/admin/unattached_promo_registrations/report';
    unattachedReferralCodeForm.method = 'get';
  });
  addListener('update-referral-code-statuses', () => {
    unattachedReferralCodeForm.action = '/admin/unattached_promo_registrations/update_statuses';
  });
})