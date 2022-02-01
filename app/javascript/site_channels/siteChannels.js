function openFailedVerificationModal() {
  let template = document.querySelector('#verification_failed_modal_wrapper');
  let closeFn = openModal(template);
}

function isAVerificationPage(){
  let isDNSVerificationPage = document.querySelectorAll('body[data-action="verification_dns_record"]').length === 1
  let isPublicFileVerificationPage = document.querySelectorAll('body[data-action="verification_public_file"]').length === 1
  let isGithubVerificationPage = document.querySelectorAll('body[data-action="verification_github"]').length === 1

  return isDNSVerificationPage || isPublicFileVerificationPage || isGithubVerificationPage
}

window.addEventListener('DOMContentLoaded', function() {

  if (!isAVerificationPage()) {
    return;
  }

  let verificationFailedElement = document.getElementById('verification_failed_modal_wrapper');

  if (verificationFailedElement.getAttribute('data-open-verification-failed-modal') === 'true') {
      openFailedVerificationModal();
    }
});
