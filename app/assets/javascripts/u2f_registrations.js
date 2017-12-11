;(function() {
  'use strict';

  /*
   * Register a u2f device
   */
  function registerU2fDevice(formElement, responseInput) {
    var appId = formElement.querySelector('[name=u2f_app_id]').value;
    var registrationRequests = JSON.parse(formElement.querySelector('[name=u2f_registration_requests]').value);
    var registeredKeys = JSON.parse(formElement.querySelector('[name=u2f_sign_requests]').value);
    window.u2f.register(appId, registrationRequests, registeredKeys, function(registerResponse) {
      switch(registerResponse.errorCode) {

        case undefined: // OK
        case 0: // OK
          responseInput.value = JSON.stringify(registerResponse);
          formElement.submit();
          return;

        case 1: // OTHER_ERROR:
          window.U2FShared.showError('u2f-error-other-error');
          break;
        case 2: // BAD_REQUEST:
          window.U2FShared.showError('u2f-error-bad-request');
          break;
        case 3: // CONFIGURATION_UNSUPPORTED:
          window.U2FShared.showError('u2f-error-configuration-unsupported');
          break;
        case 4: // DEVICE_INELIGIBLE:
          window.U2FShared.showError('u2f-error-device-ineligible');
          break;
        case 5: // TIMEOUT
          window.U2FShared.showError('u2f-error-timeout');
          break;
      }

      // Reset the form after an error to permit a second attempt
      var submit = formElement.querySelector('input[type=submit][disabled=disabled]');
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
    var formElement = document.querySelector('.js-register-u2f');
    if (formElement) {
      formElement.addEventListener('submit', function(event) {
        window.U2FShared.clearErrors('register-u2f-error');
        var responseInput = formElement.querySelector('[name=u2f_response]');
        if (!responseInput.value) {
          event.preventDefault();
          registerU2fDevice(formElement, responseInput);
        }
      });
    }
  });

})();
