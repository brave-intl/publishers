import {
  fetchAfterDelay,
  submitForm
} from '../../utils/request';

document.addEventListener('DOMContentLoaded', function() {
  var unattachedReferralCodeForm = document.getElementById('unattached-referral-code-form');

  let assignToCampaignButton = document.getElementById('assign-to-campaign')
  assignToCampaignButton.addEventListener('click', function(event){
    unattachedReferralCodeForm.action = '/admin/unattached_promo_registrations/assign'
  })

  let downloadReferralReportButton = document.getElementById('download-referral-reports')
  downloadReferralReportButton.addEventListener('click', function(event){
    unattachedReferralCodeForm.method = 'get'
    unattachedReferralCodeForm.action = '/admin/unattached_promo_registrations/report'
  })

  let updateReferralCodeStatusesButton = document.getElementById('update-referral-code-statuses')
  updateReferralCodeStatusesButton.addEventListener('click', function(event){
    unattachedReferralCodeForm.action = '/admin/unattached_promo_registrations/update_statuses'
  })
})