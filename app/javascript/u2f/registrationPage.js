import { create } from "@github/webauthn-json";
import { ErrorManager } from './shared';

/*
 * Register a u2f device
 */
async function registerU2fDevice(formElement, responseInput) {
  formElement.classList.add('js-u2f-working');

  let challenge = formElement.querySelector('[name=webauthn_challenge]').value;
  let userID = formElement.querySelector('[name=webauthn_user_id]').value;
  let userDisplayName = formElement.querySelector('[name=webauthn_user_display_name]').value;
  let exclude = JSON.parse(formElement.querySelector('[name=webauthn_exclusions]').value)

  async function register({userID, challenge, userDisplayName, exclude}) {
    return await create({
      publicKey: {
        challenge: challenge,
        rp: {name: ""},
        user: {
          id: userID,
          name: userDisplayName,
          displayName: userDisplayName,
        },
        pubKeyCredParams: [{type: "public-key", alg: -7}],
        excludeCredentials: exclude.map(x => ({id: x, type: 'public-key'})),
        authenticatorSelection: {userVerification: "discouraged"},
        extensions: {
          credProps: true,
        },
      },
    });
  }

  const result = await register({userID, challenge, userDisplayName, exclude});

  responseInput.value = JSON.stringify(result);
  formElement.submit();
}

/*
 * Setup the DOM event listeners
 *
 */
document.addEventListener('DOMContentLoaded', function() {
  let formElement = document.querySelector('.js-register-webauthn');
  if (formElement) {
    formElement.addEventListener('submit', function(event) {
      let responseInput = formElement.querySelector('[name=webauthn_response]');
      if (!responseInput.value) {
        event.preventDefault();
        registerU2fDevice(formElement, responseInput);
      }
    });
  }
});
