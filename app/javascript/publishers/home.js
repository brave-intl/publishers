import {
  fetchAfterDelay,
  submitForm
} from '../utils/request';
import fetch from '../utils/fetchPolyfill';
import flash from '../utils/flash';
import { Wallet } from '../wallet';
import { formatFullDate } from '../utils/dates';
import { renderBraveRewardsBannerContainer } from '../packs/brave_rewards_banner_container';

// ToDo - import resource strings
const NO_CURRENCY_SELECTED = 'None selected';
const SELECT_CURRENCY = '-- Select currency --';
const UNAVAILABLE = 'unavailable';

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

function updateTotalContributionBalance(balance) {
  let batAmount = document.getElementById('bat_amount');
  batAmount.innerText = balance.bat.toFixed(2);
  let convertedAmount = document.getElementById('converted_amount');

  convertedAmount.style.display = balance.currency === "BAT" || balance.currency === null ? 'none' : 'block';
  convertedAmount.innerText = formatBalance(balance.converted, balance.currency);
}

function formatBalance(amount, currency) {
  if (isNaN(amount)) {
    return `${currency} ${UNAVAILABLE}`;
  } else {
    return `~ ${amount.toFixed(2)} ${currency}`;
  }
}

function updateLastSettlement(settlement) {
  let lastSettlement = document.getElementById('last_settlement');
  let lastDepositDate = document.getElementById('last_deposit_date');
  let lastDepositBatAmount = document.getElementById('last_deposit_bat_amount');
  let lastDepositConvertedAmount = document.getElementById('last_deposit_converted_amount');

  if (settlement.date) {
    lastSettlement.classList.remove('no-settlement-made');
    lastSettlement.classList.add('settlement-made');

    lastDepositDate.innerText = formatFullDate(settlement.date);
    lastDepositBatAmount.innerText = settlement.amount.bat.toFixed(2);
    lastDepositConvertedAmount.style.display = settlement.amount.currency === "BAT" || settlement.amount.currency === null ? 'none' : 'block';
    lastDepositConvertedAmount.innerText = formatBalance(settlement.amount.converted, settlement.amount.currency);
  }
  else {
    lastSettlement.classList.remove('settlement-made');
    lastSettlement.classList.add('no-settlement-made');

    lastDepositDate.innerText = "No deposit made yet";
    lastDepositBatAmount.innerText = "";
    lastDepositConvertedAmount.style.display = 'none';
  }
}

function updateChannelBalances(wallet) {
  for (let channelId in wallet.channelBalances) {
    let channelAmount = document.getElementById('channel_amount_bat_' + channelId);
    if (channelAmount) {
      channelAmount.innerText = wallet.getChannelAmount(channelId).bat.toFixed(2);
    }
  }
}

function updateDefaultCurrencyValue(wallet) {
  let upholdStatusElement = document.getElementById('uphold_status');
  upholdStatusElement.setAttribute('data-default-currency', wallet.providerWallet.defaultCurrency || '');

  let defaultCurrencyDisplay = document.getElementById('default_currency_code');
  defaultCurrencyDisplay.innerText = wallet.providerWallet.defaultCurrency || NO_CURRENCY_SELECTED;
}

function updatePossibleCurrencies(wallet) {
  let possibleCurrencies = wallet.providerWallet.possibleCurrencies || [];
  let upholdStatusElement = document.getElementById('uphold_status');
  upholdStatusElement.setAttribute('data-possible-currencies', JSON.stringify(possibleCurrencies));
}

function getPossibleCurrencies() {
  let upholdStatusElement = document.getElementById('uphold_status');
  return JSON.parse(upholdStatusElement.getAttribute('data-possible-currencies'));
}

function populateCurrencySelect(select, possibleCurrencies, selectedCurrency) {
  select.innerHTML = '';

  if (!selectedCurrency || selectedCurrency.length === 0) {
    let option = document.createElement('option');
    option.value = '';
    option.innerHTML = SELECT_CURRENCY;
    option.selected = true
    select.appendChild(option);
  }

  possibleCurrencies.forEach(currency => {
    let option = document.createElement('option');
    option.value = currency;
    option.innerHTML = currency;
    option.selected = (currency === selectedCurrency);
    select.appendChild(option);
  });
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
      let wallet = new Wallet(body);

      updateDefaultCurrencyValue(wallet);

      updatePossibleCurrencies(wallet);

      let contributionAmount = wallet.totalAmount;
      updateTotalContributionBalance(contributionAmount);

      let lastSettlement = wallet.lastSettlement;
      updateLastSettlement(lastSettlement);

      updateChannelBalances(wallet);

      if (!wallet.providerWallet.defaultCurrency && wallet.providerWallet.authorized) {
        openDefaultCurrencyModal();
      }
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
      let upholdStatusDescription = document.querySelector('#uphold_connect .status-description');
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
          upholdStatusDescription.innerHTML = body.uphold_status_description;
        }

        if (checkUpholdStatusInterval != null &&
            (timedOut ||
             body.uphold_status === 'verified' ||
             body.uphold_status === 'incomplete')) {

          clearInterval(checkUpholdStatusInterval);
          checkUpholdStatusInterval = null;

          if (body.uphold_status === 'verified') {
            refreshBalance();
          }
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

  // Sync default currency selected in modal with options and value from dashboard
  let upholdStatusElement = document.getElementById('uphold_status');
  let currentDefaultCurrency = upholdStatusElement.getAttribute('data-default-currency');
  let currencySelectInModal = document.getElementById('publisher_default_currency');
  populateCurrencySelect(currencySelectInModal, getPossibleCurrencies(), currentDefaultCurrency || "");

  form.addEventListener('submit', function(event) {
    event.preventDefault();

    let modal = document.getElementById('confirm_default_currency_modal');
    let status = document.querySelector('#confirm_default_currency_modal .status');

    if (!currencySelectInModal.value) {
      closeFn();
      return;
    }

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

function showWhatHappenedVerificationFailure() {
  let elementToReveal = this.nextSibling;
  elementToReveal.style.display = "block";
}

function hideVerificationFailureWhatHappened(element) {
  let elementToHide = element.nextSibling
  elementToHide.style.display = "none"
}

document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelectorAll('body[data-action="home"]').length === 0) {
    return;
  }

  let upholdStatusElement = document.getElementById('uphold_status');

  if (upholdStatusElement.classList.contains('uphold-processing')) {
    checkUpholdStatusInterval = window.setInterval(checkUpholdStatus, 2000);

  } else if (upholdStatusElement.getAttribute('data-open-confirm-default-currency-modal') === 'true') {
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
  if (disconnectUpholdLink) {
    disconnectUpholdLink.addEventListener('click', function(event) {
      let template = document.querySelector('[id="disconnect-uphold-js"]');
      openModal(template.innerHTML, function() {
        disconnectUphold();
      }, function() {
      });
      event.preventDefault();
    }, false);
  }

  let publisherVisibleCheckbox = document.getElementById('publisher_visible');
  publisherVisibleCheckbox.addEventListener('click', function(event) {
    submitForm('update_publisher_visible_form', 'PATCH', true);
  }, false);

  let changeDefaultCurrencyLink = document.getElementById('change_default_currency');
  if (changeDefaultCurrencyLink) {
    changeDefaultCurrencyLink.addEventListener('click', function(event) {
      openDefaultCurrencyModal();
      event.preventDefault();
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

  let verificationFailureWhatHappenedElements = document.getElementsByClassName('verification-failed--what-happened');

  for (let i=0; i<verificationFailureWhatHappenedElements.length; i++) {
    verificationFailureWhatHappenedElements[i].addEventListener('click', showWhatHappenedVerificationFailure, false);
  }

  // Hide all verification failed bubbles when anywhere on DOM is clicked
  document.body.addEventListener('click', function(event) {
    for (var i=0; i<verificationFailureWhatHappenedElements.length; i++) {
      // Do not hide if the clicked element is supposed to show the bubble
      // Or if the clicked element is the bubble
      let e = verificationFailureWhatHappenedElements[i];
      if (e === event.target || e.nextSibling == event.target || e.nextSibling.firstChild == event.target) {
        continue;
      } else {
        hideVerificationFailureWhatHappened(e);
      }
    }
  })

  let instantDonationButton = document.getElementById("instant-donation-button");

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

  instantDonationButton.addEventListener("click", function(event) {
    document.getElementsByClassName('container')[0].style.padding = 0;
    renderBraveRewardsBannerContainer();
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
