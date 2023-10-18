import './u2f-api';
import { ErrorManager } from './shared';
import { get } from "@github/webauthn-json";

/*
 * Register a u2f device
 */
async function authenticate(formElement, responseInput, errorManager) {
  formElement.classList.add('js-u2f-working');

  let appId = formElement.querySelector('[name=webauthn_u2f_app_id]').value;
  let challenge = formElement.querySelector('[name=webauthn_u2f_challenge]').value;
  let signRequests = JSON.parse(formElement.querySelector('[name=webauthn_u2f_sign_requests]').value);

  async function authenticate({appId, challenge, signRequests}) {
    return await get({
      publicKey: {
        challenge: challenge,
        allowCredentials: signRequests.map(x => ({id: x, type: 'public-key'})),
        extensions: {
          "appid": appId
        },
        userVerification: "discouraged",
      },
    });
  }

  // {
  //   "type": "public-key",
  //     "id": "WGy....",
  //     "rawId": "PLe...",
  //     "response": {
  //   "clientDataJSON": "re...",
  //       "authenticatorData": "i-vH...",
  //       "signature": "VCV-....",
  //       "userHandle": null
  // },
  //   "clientExtensionResults": {
  //   "appid": true
  // }
  // }
  const result = await authenticate({appId, challenge, signRequests});

  // Errors handled by browser built-in
  responseInput.value = JSON.stringify(result);
  formElement.submit();
}

/*
 * Setup the DOM event listeners
 *
 */
document.addEventListener('DOMContentLoaded', function() {
  let formElement = document.querySelector('.js-authenticate-u2f');
  if (formElement) {
    let responseInput = formElement.querySelector('[name=webauthn_u2f_response]');
    let errorManager = new ErrorManager('authenticate-u2f-error');
    formElement.addEventListener('submit', function(event) {
      errorManager.clear();
      if (!responseInput.value) {
        event.preventDefault();
        authenticate(formElement, responseInput, errorManager);
      }
    });
    authenticate(formElement, responseInput, errorManager);
  }
});
