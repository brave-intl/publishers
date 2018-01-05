import './u2f-api';
import {
  clearErrors,
  showError
} from './shared';

/*
 * Register a u2f device
 */
function authenticate(formElement, responseInput) {
  formElement.classList.add('js-u2f-working');

  let appId = formElement.querySelector('[name=u2f_app_id]').value;
  let challenge = JSON.parse(formElement.querySelector('[name=u2f_challenge]').value);
  let signRequests = JSON.parse(formElement.querySelector('[name=u2f_sign_requests]').value);
  window.u2f.sign(appId, challenge, signRequests, function(signingResponse) {
    switch(signingResponse.errorCode) {

      case undefined: // OK
      case 0: // OK
        responseInput.value = JSON.stringify(signingResponse);
        formElement.submit();
        return;

      case 1: // OTHER_ERROR:
        showError('u2f-error-other-error');
        break;
      case 2: // BAD_REQUEST:
        showError('u2f-error-bad-request');
        break;
      case 3: // CONFIGURATION_UNSUPPORTED:
        showError('u2f-error-configuration-unsupported');
        break;
      case 4: // DEVICE_INELIGIBLE:
        showError('u2f-error-device-ineligible');
        break;
      case 5: // TIMEOUT
        showError('u2f-error-timeout');
        break;
      case 99900: // IMPLEMENTATION_INCOMPLETE
        showError('u2f-error-implementation-incomplete');
        break;
    }

    formElement.classList.remove('js-u2f-working');
    // Reset the form after an error to permit a second attempt
    let submit = formElement.querySelector('input[type=submit][disabled=disabled]');
    if (submit) {
      submit.removeAttribute('disabled');
      submit.blur();
    }
  });
}

/*
 * Setup the DOM event listeners
 *
 */
document.addEventListener('DOMContentLoaded', function() {
  let formElement = document.querySelector('.js-authenticate-u2f');

  if (formElement && window.u2f) {
    let responseInput = formElement.querySelector('[name=u2f_response]');
    formElement.addEventListener('submit', function(event) {
      clearErrors('register-u2f-error');
      if (!responseInput.value) {
        event.preventDefault();
        authenticate(formElement, responseInput);
      }
    });
    authenticate(formElement, responseInput);
  }
});
