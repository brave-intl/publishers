import {
  fetchAfterDelay,
  pollUntilSuccess,
  submitForm
} from '../utils/request';
import dynamicEllipsis from '../utils/dynamicEllipsis';
import '../userMenu';

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
    });
}

let checkUpholdStatusInterval;
let checkUpholdStatusCount = 0;

function checkUpholdStatus() {
  let options = {
    headers: {
      'Accept': 'application/json'
    },
    credentials: 'same-origin',
    method: 'GET'
  };

  return window.fetch('./status', options)
    .then(function(response) {
      checkUpholdStatusCount += 1;
      if (response.status === 200 || response.status === 304) {
        return response.json();
      }
    })
    .then(function(body) {
      let upholdDashboard = document.getElementById('uphold_dashboard');
      if (body.uphold_status_class) {
        upholdDashboard.className = body.uphold_status_class;
      }

      if (body.uphold_status === 'verified') {
        document.getElementById('publisher_status').innerText = body.uphold_status_description;
        let publisherStatus = document.getElementById('publisher_status');
        publisherStatus.innerText = body.status_description;
        publisherStatus.className = body.status;
        document.getElementById('uphold_connect').classList.add('hidden');
        document.getElementById('statement_section').classList.remove('hidden');
        dynamicEllipsis.stop('publisher_status');
        clearInterval(checkUpholdStatusInterval);
      } else if (checkUpholdStatusCount >= 15) {
        let publisherStatus = document.getElementById('publisher_status');
        publisherStatus.innerText = body.timeout_message;
        dynamicEllipsis.stop('publisher_status');
        clearInterval(checkUpholdStatusInterval);
      }
    });
}

document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelectorAll('body[data-action="home"]').length === 0) {
    return;
  }

  if (document.querySelectorAll('div#uphold_dashboard.uphold-status-access-parameters-acquired').length > 0) {
    window.dynamicEllipsis.start('publisher_status');
    checkUpholdStatusInterval = window.setInterval(checkUpholdStatus, 2000);
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

  let generateStatement = document.getElementById('generate_statement');
  let statementGenerator = document.getElementById('statement_generator');
  let statementPeriod = document.getElementById('statement_period');
  let generatedStatements = document.getElementById('generated_statements');

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

  if (generateStatement) {
    generateStatement.addEventListener('click', function(event) {
      let statementId;
      let statementDownloadDiv;

      event.preventDefault();
      generateStatement.classList.add('hidden');

      submitForm('statement_generator', 'PATCH', false)
        .then(function(response) {
          return response.json();
        })
        .then(function(json) {
          statementPeriod.options.remove(statementPeriod.selectedIndex);
          if (statementPeriod.options.length === 0) {
            statementGenerator.classList.add('hidden');
          }

          let newStatementDiv = document.createElement('div');
          newStatementDiv.className = 'statement';

          let statementPeriodDiv = document.createElement('div');
          statementPeriodDiv.className = 'period';
          statementPeriodDiv.appendChild(document.createTextNode(json.period));
          newStatementDiv.appendChild(statementPeriodDiv);

          statementDownloadDiv = document.createElement('div');
          statementDownloadDiv.className = 'download';
          statementDownloadDiv.appendChild(document.createTextNode('Generating'));
          newStatementDiv.appendChild(statementDownloadDiv);

          generatedStatements.insertBefore(newStatementDiv, generatedStatements.firstChild);

          dynamicEllipsis.start(statementDownloadDiv);

          statementId = json.id;
          return pollUntilSuccess('/publishers/statement_ready?id=' + statementId, 3000, 2000, 7);
        })
        .then(function() {
          dynamicEllipsis.stop(statementDownloadDiv);
          statementDownloadDiv.innerHTML = '<a href="/publishers/statement?id=' + statementId + '">Download</a>';
          generateStatement.classList.remove('hidden');
        })
        .catch(function(e) {
          if (statementDownloadDiv) {
            dynamicEllipsis.stop(statementDownloadDiv);
            statementDownloadDiv.innerText = 'Delayed';
          }
          generateStatement.classList.remove('hidden');
        });
    }, false);
  }
});
