import './u2f-api';
import {
  clearErrors,
  showError
} from './shared';

/*
 * Register a u2f device
 */
function registerU2fDevice(formElement, responseInput) {
  let appId = formElement.querySelector('[name=u2f_app_id]').value;
  let registrationRequests = JSON.parse(formElement.querySelector('[name=u2f_registration_requests]').value);
  let registeredKeys = JSON.parse(formElement.querySelector('[name=u2f_sign_requests]').value);
  window.u2f.register(appId, registrationRequests, registeredKeys, function(registerResponse) {
    clearErrors('register-u2f-waiting');

    switch(registerResponse.errorCode) {

      case undefined: // OK
      case 0: // OK
        responseInput.value = JSON.stringify(registerResponse);
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
  let formElement = document.querySelector('.js-register-u2f');
  if (formElement) {
    formElement.addEventListener('submit', function(event) {
      clearErrors('register-u2f-error');
      let responseInput = formElement.querySelector('[name=u2f_response]');
      if (!responseInput.value) {
        event.preventDefault();
        showError('u2f-waiting');
        registerU2fDevice(formElement, responseInput);
      }
    });
  }
});
