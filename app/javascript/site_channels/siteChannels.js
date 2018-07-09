function openFailedVerificationModal() {
  let template = document.querySelector('#verification_failed_modal_wrapper');
  let closeFn = openModal(template.innerHTML);
}

function isAVerificationPage(){
  isDNSVerificationPage = document.querySelectorAll('body[data-action="verification_dns_record"]').length === 1
  isPublicFileVerificationPage = document.querySelectorAll('body[data-action="verification_public_file"]').length === 1
  isWordPressVerificationPage = document.querySelectorAll('body[data-action="verification_wordpress"]').length === 1
  isGithubVerificationPage = document.querySelectorAll('body[data-action="verification_github"]').length === 1

  return isDNSVerificationPage || isPublicFileVerificationPage || isWordPressVerificationPage || isGithubVerificationPage
}

window.addEventListener('load', function() {

  if (!isAVerificationPage()) {
    return;
  }

  let verificationFailedElement = document.getElementById('verification_failed_modal_wrapper');
  
  if (verificationFailedElement.getAttribute('data-open-verification-failed-modal') === 'true') {
      openFailedVerificationModal();
    }
});