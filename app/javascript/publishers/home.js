function showPendingContactEmail(pendingEmail) {
  var pendingEmailNotice = document.getElementById('pending_email_notice');
  var showContactEmail = document.getElementById('show_contact_email');
  if (pendingEmail && pendingEmail != showContactEmail.innerText) {
    pendingEmailNotice.innerHTML = 'Pending: Email address has been updated to: <strong>' + pendingEmail + '</strong>. An email has been sent to this address to confirm this change.';
    pendingEmailNotice.style.display = 'block';
  } else {
    pendingEmailNotice.style.display = 'none';
  }
}

function refreshBalance() {
  var options = {
    headers: {
        'Accept': 'application/json'
    },
    credentials: 'same-origin',
    method: 'GET'
  };

  return window.fetchAfterDelay('./balance', 500)
    .then(function(response) {
      if (response.status === 200 || response.status === 304) {
        return response.json();
      }
    })
    .then(function(body) {
      var batAmount = document.getElementById('bat_amount');
      batAmount.innerText = body.bat_amount;
      var convertedAmount = document.getElementById('converted_amount');
      convertedAmount.innerText = body.converted_balance;
    });
}

function showVerificationModal() {
  var modal = document.getElementById('verification_modal');
  modal.classList.add('md-show');
}

function hideVerificationModal() {
  var modal = document.getElementById('verification_modal');
  modal.classList.remove('md-show');
}

function removeChannel(channelId) {
  submitForm('remove_channel_' + channelId, 'DELETE', true)
    .then(function(response) {
      var channelRow = document.getElementById('channel_row_' + channelId);
      channelRow.classList.add('channel-hidden');

      // Show channel placeholder if no channels are still visible
      var visibleChannelRows = document.querySelectorAll("div.channel-row:not(.channel-hidden)");
      if (visibleChannelRows.length === 0) {
        var addChannelPlaceholder = document.getElementById("add_channel_placeholder");
        addChannelPlaceholder.classList.remove("hidden");
      }
    });
}

document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelectorAll('body[data-action="home"]').length === 0) {
    return;
  }

  var removeChannelLinks = document.querySelectorAll('a.remove-channel');
  for (var i = 0, l = removeChannelLinks.length; i < l; i++) {
    removeChannelLinks[i].addEventListener('click', function(event) {
      var channelId = event.target.getAttribute('data-channel-id');
      var template = document.querySelector('[data-js-channel-removal-confirmation-template="' + channelId + '"]');
      openModal(template.innerHTML, function() {
        removeChannel(channelId);
      }, function() {
      });
      event.preventDefault();
    }, false);
  }

  var publisherVisibleCheckbox = document.getElementById('publisher_visible');
  publisherVisibleCheckbox.addEventListener('click', function(event) {
    window.submitForm('update_publisher_visible_form', 'PATCH', true);
  }, false);

  var defaultCurrencySelect = document.getElementById('publisher_default_currency');
  if (defaultCurrencySelect) {
    defaultCurrencySelect.addEventListener('change', function(event) {
      window.submitForm('update_default_currency_form', 'PATCH', true);
      refreshBalance();
    }, false);
  }

  var showContact = document.getElementById('show_contact');
  var showContactName = document.getElementById('show_contact_name');
  var showContactEmail = document.getElementById('show_contact_email');
  var showContactPhone = document.getElementById('show_contact_phone');
  var showContactPhoneSeparator = document.getElementById('show_contact_phone_separator');

  var pendingContactEmail = document.getElementById('pending_contact_email');
  showPendingContactEmail(pendingContactEmail.innerText);

  var updateContactForm = document.getElementById('update_contact');
  var updateContactName = document.getElementById('update_contact_name');
  var updateContactEmail = document.getElementById('update_contact_email');
  var updateContactPhone = document.getElementById('update_contact_phone');

  var editContact = document.getElementById('edit_contact');
  var cancelEditContact = document.getElementById('cancel_edit_contact');

  var generateStatement = document.getElementById('generate_statement');
  var generateStatementResult = document.getElementById('generate_statement_result');
  var statementGenerator = document.getElementById('statement_generator');
  var statementPeriod = document.getElementById('statement_period');
  var generatedStatements = document.getElementById('generated_statements');

  editContact.addEventListener('click', function(event) {
    updateContactName.value = showContactName.innerText;
    updateContactEmail.value = pendingContactEmail.innerText || showContactEmail.innerText;
    updateContactPhone.value = showContactPhone.innerText;
    showContact.style.display = 'none';
    updateContactForm.style.display = 'block';
    editContact.style.display = 'none';
    updateContactName.focus();
    event.preventDefault();
  }, false);

  cancelEditContact.addEventListener('click', function(event) {
    showContact.style.display = 'block';
    updateContactForm.style.display = 'none';
    editContact.style.display = 'block';
    event.preventDefault();
  }, false);

  updateContactForm.addEventListener('submit', function(event) {
    event.preventDefault();
    window.submitForm('update_contact', 'PATCH', true)
      .then(function() {
        var updatedEmail = updateContactEmail.value;
        showContactName.innerText = updateContactName.value;
        showContactPhone.innerText = updateContactPhone.value;
        pendingContactEmail.innerText = updatedEmail;
        showPendingContactEmail(updatedEmail);

        updateContactForm.style.display = 'none';
        showContact.style.display = 'block';
        editContact.style.display = 'block';
        showContactPhoneSeparator.style.display = (showContactPhone.innerText ? 'inline' : 'none');

        // Re-enable submit button to allow form to be resubmitted
        var submitButton = updateContactForm.querySelector('input[type=submit][disabled]');
        if (submitButton) {
          submitButton.removeAttribute('disabled');
          submitButton.blur();
        }
      });
  }, false);

  if (generateStatement) {
    generateStatement.addEventListener('click', function(event) {
      var statementId;
      var statementDownloadDiv;

      event.preventDefault();
      generateStatement.style.display = 'none';

      window.submitForm('statement_generator', 'PATCH', false)
        .then(function(response) {
          return response.json();
        })
        .then(function(json) {
          statementPeriod.options.remove(statementPeriod.selectedIndex);
          if (statementPeriod.options.length === 0) {
            statementGenerator.style.display = 'none';
          }

          var newStatementDiv = document.createElement('div');
          newStatementDiv.className = 'statement';

          var statementPeriodDiv = document.createElement('div');
          statementPeriodDiv.className = 'period';
          statementPeriodDiv.appendChild(document.createTextNode(json.period));
          newStatementDiv.appendChild(statementPeriodDiv);

          statementDownloadDiv = document.createElement('div');
          statementDownloadDiv.className = 'download';
          statementDownloadDiv.appendChild(document.createTextNode('Generating'));
          newStatementDiv.appendChild(statementDownloadDiv);

          generatedStatements.insertBefore(newStatementDiv, generatedStatements.firstChild);

          window.dynamicEllipsis.start(statementDownloadDiv);

          statementId = json.id;
          return window.pollUntilSuccess('/publishers/statement_ready?id=' + statementId, 3000, 2000, 7);
        })
        .then(function() {
          window.dynamicEllipsis.stop(statementDownloadDiv);
          statementDownloadDiv.innerHTML = '<a href="/publishers/statement?id=' + statementId + '">Download</a>';
          generateStatement.style.display = 'inline-block';
        })
        .catch(function(e) {
          if (statementDownloadDiv) {
            window.dynamicEllipsis.stop(statementDownloadDiv);
            statementDownloadDiv.innerText = 'Delayed';
          }
          generateStatement.style.display = 'inline-block';
        });
    }, false);
  }
});
