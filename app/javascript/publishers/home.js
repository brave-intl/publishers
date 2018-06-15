import {
  fetchAfterDelay,
  submitForm
} from '../utils/request';
import fetch from '../utils/fetchPolyfill';
import flash from '../utils/flash';

function showPendingContactEmail(pendingEmail) {
  let pendingEmailNotice = document.getElementById('pending_email_notice');
  let showContactEmail = document.getElementById('show_contact_email');
  if (pendingEmail && pendingEmail != showContactEmail.innerText) {
    pendingEmailNotice.innerHTML = `Pending: Email address has been updated to: <strong>${pendingEmail}</strong>. An email has been sent to this address to confirm this change.`;
    pendingEmailNotice.classList.remove('hidden');
  } else {
    pendingEmailNotice.classList.add('hidden');
  }
}

function refreshBalance() {
  let options = {
    headers: {
        'Accept': 'application/json'
    },
    credentials: 'same-origin',
    method: 'GET'
  };

  return fetchAfterDelay('./balance', 500)
    .then(function(response) {
      if (response.status === 200 || response.status === 304) {
        return response.json();
      }
    })
    .then(function(body) {
      let batAmount = document.getElementById('bat_amount');
      batAmount.innerText = body.bat_amount;
      let convertedAmount = document.getElementById('converted_amount');
      convertedAmount.innerText = body.converted_balance;
    });
}

function removeChannel(channelId) {
  submitForm('remove_channel_' + channelId, 'DELETE', true)
    .then(function(response) {
      let channelRow = document.getElementById('channel_row_' + channelId);
      channelRow.classList.add('channel-hidden');

      // Show channel placeholder if no channels are still visible
      let visibleChannelRows = document.querySelectorAll("div.channel-row:not(.channel-hidden)");
      if (visibleChannelRows.length === 0) {
        let addChannelPlaceholder = document.getElementById("add_channel_placeholder");
        addChannelPlaceholder.classList.remove("hidden");
      }
      flash.clear();
      flash.append('info', channelRow.getAttribute('data-remove-message'));
    });
}

let checkUpholdStatusInterval = null;
let checkUpholdStatusCount = 0;

function checkUpholdStatus() {
  let options = {
    headers: {
      'Accept': 'application/json'
    },
    credentials: 'same-origin',
    method: 'GET'
  };

  return fetch('./uphold_status', options)
    .then(function(response) {
      checkUpholdStatusCount += 1;
      if (response.status === 200 || response.status === 304) {
        return response.json();
      }
    })
    .then(function(body) {
      let upholdStatus = document.getElementById('uphold_status');
      let upholdStatusSummary = document.querySelector('#uphold_status_display .status-summary .text');
      let upholdStatusDescription = document.querySelector('#uphold_status_display .status-description');
      let timedOut = (checkUpholdStatusCount >= 15);

      if (timedOut) {
        // TODO - use resource strings for summary + description text
        body = {
          uphold_status_class: 'uphold-timeout',
          uphold_status_summary: 'Connection problems',
          uphold_status_description: 'We are experiencing communication problems. Please check back later.'
        };
      }

      if (body) {
        if (body.uphold_status_class) {
          upholdStatus.className = body.uphold_status_class;
        }

        if (body.uphold_status_summary) {
          upholdStatusSummary.innerText = body.uphold_status_summary;
        }

        if (body.uphold_status_description) {
          upholdStatusDescription.innerText = body.uphold_status_description;
        }

        if (checkUpholdStatusInterval != null && (body.uphold_status === 'verified' || timedOut)) {
          clearInterval(checkUpholdStatusInterval);
          checkUpholdStatusInterval = null;
        }
      }
    });
}

function disconnectUphold() {
  submitForm('disconnect_uphold', 'PATCH', true)
    .then(function(response) {
      return checkUpholdStatus();
    });
}

function openDefaultCurrencyModal() {
  let template = document.querySelector('#confirm_default_currency_modal_wrapper');
  let closeFn = openModal(template.innerHTML);

  let form = document.getElementById('confirm_default_currency_form');

  form.addEventListener('submit', function(event) {
    event.preventDefault();

    let modal = document.getElementById('confirm_default_currency_modal');
    let status = document.querySelector('#confirm_default_currency_modal .status');

    modal.classList.add('transitioning');

    submitForm('confirm_default_currency_form', 'PATCH', false)
      .then(response => response.json())
      .then(body => {
        status.innerHTML = body.status;
        setTimeout(
          function() {
            if (body.action === 'redirect') {
              window.location.href = body.redirectURL;
            } else if (body.action === 'refresh' ) {
              refreshBalance()
                .then(() => closeFn());
            } else {
              closeFn();
            }
          },
          body.timeout
        );
      });
  }, false);
}

document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelectorAll('body[data-action="home"]').length === 0) {
    return;
  }

  if (document.querySelectorAll('div#uphold_status.uphold-processing').length > 0) {
    checkUpholdStatusInterval = window.setInterval(checkUpholdStatus, 2000);
  }

  let dashboard = document.querySelector('.dashboard');
  if (dashboard.getAttribute('data-open-confirm-default_currency-modal') === 'true') {
    openDefaultCurrencyModal();
  }

  let removeChannelLinks = document.querySelectorAll('a.remove-channel');
  for (let i = 0, l = removeChannelLinks.length; i < l; i++) {
    removeChannelLinks[i].addEventListener('click', function(event) {
      let channelId = event.target.getAttribute('data-channel-id');
      let template = document.querySelector('[data-js-channel-removal-confirmation-template="' + channelId + '"]');
      openModal(template.innerHTML, function() {
        removeChannel(channelId);
      }, function() {
      });
      event.preventDefault();
    }, false);
  }

  let disconnectUpholdLink = document.querySelector('a.disconnect-uphold');
  disconnectUpholdLink.addEventListener('click', function(event) {
    let template = document.querySelector('[id="disconnect-uphold-js"]');
    openModal(template.innerHTML, function() {
      disconnectUphold();
    }, function() {
    });
    event.preventDefault();
  }, false);

  let publisherVisibleCheckbox = document.getElementById('publisher_visible');
  publisherVisibleCheckbox.addEventListener('click', function(event) {
    submitForm('update_publisher_visible_form', 'PATCH', true);
  }, false);

  let defaultCurrencySelect = document.getElementById('publisher_default_currency');
  if (defaultCurrencySelect) {
    defaultCurrencySelect.addEventListener('change', function(event) {
      submitForm('update_default_currency_form', 'PATCH', true);
      refreshBalance();
    }, false);
  }

  let showContact = document.getElementById('show_contact');
  let showContactName = document.getElementById('show_contact_name');
  let showContactEmail = document.getElementById('show_contact_email');
  let showContactPhone = document.getElementById('show_contact_phone');
  let showContactPhoneSeparator = document.getElementById('show_contact_phone_separator');

  let pendingContactEmail = document.getElementById('pending_contact_email');
  showPendingContactEmail(pendingContactEmail.innerText);

  let updateContactForm = document.getElementById('update_contact');
  let updateContactName = document.getElementById('update_contact_name');
  let updateContactEmail = document.getElementById('update_contact_email');
  let updateContactPhone = document.getElementById('update_contact_phone');

  let editContact = document.getElementById('edit_contact');
  let cancelEditContact = document.getElementById('cancel_edit_contact');

  editContact.addEventListener('click', function(event) {
    updateContactName.value = showContactName.innerText;
    updateContactEmail.value = pendingContactEmail.innerText || showContactEmail.innerText;
    updateContactPhone.value = showContactPhone.innerText;
    showContact.classList.add('hidden');
    updateContactForm.classList.remove('hidden');
    editContact.classList.add('hidden');
    updateContactName.focus();
    event.preventDefault();
  }, false);

  cancelEditContact.addEventListener('click', function(event) {
    showContact.classList.remove('hidden');
    updateContactForm.classList.add('hidden');
    editContact.classList.remove('hidden');
    event.preventDefault();
  }, false);

  updateContactForm.addEventListener('submit', function(event) {
    event.preventDefault();
    submitForm('update_contact', 'PATCH', true)
      .then(function(response) {
        if (response.ok === true) {
          let updatedEmail = updateContactEmail.value;
          showContactName.innerText = updateContactName.value;
          showContactPhone.innerText = updateContactPhone.value;
          pendingContactEmail.innerText = updatedEmail;
          showPendingContactEmail(updatedEmail);

          let currentUserName = document.querySelector('.js-current-user-name');
          let userNameDropDown = document.querySelector('.js-user-name-dropdown');
          currentUserName.innerText = updateContactName.value;
          userNameDropDown.innerText = updateContactName.value;
        } else {
          let pendingEmailNotice = document.getElementById('pending_email_notice');
          pendingEmailNotice.innerHTML = 'Unable to change email; the email address may be in use. Please enter a different email address.';
          pendingEmailNotice.classList.remove('hidden');
        }

        updateContactForm.classList.add('hidden');
        showContact.classList.remove('hidden');
        editContact.classList.remove('hidden');
        if (showContactPhone.innerText) {
          showContactPhoneSeparator.classList.remove('hidden');
        } else {
          showContactPhoneSeparator.classList.add('hidden');
        }

        // Re-enable submit button to allow form to be resubmitted
        let submitButton = updateContactForm.querySelector('input[type=submit][disabled]');
        if (submitButton) {
          submitButton.removeAttribute('disabled');
          submitButton.blur();
        }
      });
  }, false);
});
