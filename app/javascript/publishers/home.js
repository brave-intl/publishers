import { fetchAfterDelay, submitForm } from "../utils/request";
import "babel-polyfill";
import fetch from "../utils/fetchPolyfill";
import flash from "../utils/flash";
import { Wallet } from "../wallet";
import { formatFullDate } from "../utils/dates";
import { renderBannerEditor } from "../packs/banner_editor";

// ToDo - import resource strings
const NO_CURRENCY_SELECTED = "None selected";
const SELECT_CURRENCY = "---";
const BASIC_ATTENTION_TOKEN = "BAT";
const UNAVAILABLE = "unavailable";

function formatConvertedBalance(amount, currency) {
  if (isNaN(amount) || amount === null) {
    return `${currency} ${UNAVAILABLE}`;
  } else {
    let formattedAmount = formatAmount(amount);
    return `~ ${formattedAmount} ${currency}`;
  }
}

// Ensures amounts always have two decimal places
function formatAmount(amount) {
  return (Math.round(parseFloat(amount) * 100) / 100).toFixed(2);
}


function updateOverallBalance(balance) {
  let batAmount = document.getElementById("bat_amount");
  batAmount.innerText = formatAmount(balance.amount_bat);
  let convertedAmount = document.getElementById("converted_amount");

  if (
    !(balance.default_currency === "BAT" || balance.default_currency === null)
  ) {
    convertedAmount.style.display = "block";
    convertedAmount.innerText = formatConvertedBalance(
      balance.amount_default_currency,
      balance.default_currency
    );
  }
}

function updateChannelBalances(wallet) {
  for (let channelId in wallet.channelBalances) {
    let channelAmount = document.getElementById(
      "channel_amount_bat_" + channelId
    );
    if (channelAmount) {
      channelAmount.innerText = formatAmount(
        wallet.channelBalances[channelId].amount_bat
      );
    }
  }
}

function updateDefaultCurrencyValue(defaultCurrency) {
  let upholdStatusElement = document.getElementById("uphold_status");
  upholdStatusElement.setAttribute(
    "data-default-currency",
    defaultCurrency || ""
  );

  let defaultCurrencyDisplay = document.getElementById("default_currency_code");
  defaultCurrencyDisplay.innerText = defaultCurrency || NO_CURRENCY_SELECTED;
}

function updatePossibleCurrencies(possibleCurrencies) {
  let upholdStatusElement = document.getElementById("uphold_status");
  upholdStatusElement.setAttribute(
    "data-possible-currencies",
    JSON.stringify(possibleCurrencies)
  );
}

function getPossibleCurrencies() {
  let upholdStatusElement = document.getElementById("uphold_status");
  return JSON.parse(
    upholdStatusElement.getAttribute("data-possible-currencies")
  );
}

function populateCurrencySelect(select, possibleCurrencies, selectedCurrency) {
  select.innerHTML = "";

  if (!selectedCurrency || selectedCurrency.length === 0) {
    let option = document.createElement("option");
    option.value = "";
    option.innerHTML = SELECT_CURRENCY;
    option.selected = true;
    select.appendChild(option);
  }

  possibleCurrencies.forEach(currency => {
    let option = document.createElement("option");
    option.value = currency;
    option.innerHTML = currency;
    if (
      (!selectedCurrency || selectedCurrency.length === 0) &&
      currency === BASIC_ATTENTION_TOKEN
    ) {
      option.selected = true;
    } else {
      option.selected = currency === selectedCurrency;
    }
    select.appendChild(option);
  });
}

function refreshBalance() {
  let options = {
    headers: {
      Accept: "application/json"
    },
    credentials: "same-origin",
    method: "GET"
  };

  return fetchAfterDelay("./wallet", 500)
    .then(function(response) {
      if (response.status === 200 || response.status === 304) {
        return response.json();
      }
    })
    .then(function(body) {
      let wallet = new Wallet(body.wallet);

      updateDefaultCurrencyValue(body.uphold_connection.default_currency);
      updatePossibleCurrencies(body.possible_currencies);

      let overallBalance = wallet.overallBalance;
      updateOverallBalance(overallBalance);

      updateChannelBalances(wallet);

      if (
        !body.uphold_connection.default_currency &&
        body.uphold_connection["can_create_uphold_cards?"]
      ) {
        openDefaultCurrencyModal();
      }
    });
}

function removeChannel(channelId) {
  submitForm("remove_channel_" + channelId, "DELETE", true).then(function(
    response
  ) {
    let channelRow = document.getElementById("channel_row_" + channelId);
    channelRow.classList.add("channel-hidden");

    // Show channel placeholder if no channels are still visible
    let visibleChannelRows = document.querySelectorAll(
      "div.channel-row:not(.channel-hidden)"
    );
    if (visibleChannelRows.length === 0) {
      let addChannelPlaceholder = document.getElementById(
        "add_channel_placeholder"
      );
      addChannelPlaceholder.classList.remove("hidden");
    }
    flash.clear();
    flash.append("info", channelRow.getAttribute("data-remove-message"));
  });
}

let checkUpholdStatusInterval = null;
let checkUpholdStatusCount = 0;

function checkUpholdStatus() {
  let options = {
    headers: {
      Accept: "application/json"
    },
    credentials: "same-origin",
    method: "GET"
  };

  return fetch("./uphold_status", options)
    .then(function(response) {
      checkUpholdStatusCount += 1;
      if (response.status === 200 || response.status === 304) {
        return response.json();
      }
    })
    .then(function(body) {
      let upholdStatus = document.getElementById("uphold_status");
      let upholdStatusSummary = document.querySelector(
        "#uphold_status_display .status-summary .text"
      );
      let upholdStatusDescription = document.querySelector(
        "#uphold_connect .status-description"
      );
      let timedOut = checkUpholdStatusCount >= 15;

      if (timedOut) {
        // TODO - use resource strings for summary + description text
        body = {
          uphold_status_class: "uphold-timeout",
          uphold_status_summary: "Connection problems",
          uphold_status_description:
            "We are experiencing communication problems. Please check back later."
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

        if (
          checkUpholdStatusInterval != null &&
          (timedOut ||
            body.uphold_status === "verified" ||
            body.uphold_status === "restricted")
        ) {
          hideReconnectButton();

          clearInterval(checkUpholdStatusInterval);
          checkUpholdStatusInterval = null;

          if (body.uphold_status === "verified") {
            refreshBalance();
          } else if (body.uphold_status === "restricted") {
            showUpholdSupportButton();
          }
        }
      }
    });
}

function hideReconnectButton() {
  document.getElementById("reconnect_to_uphold").style.display = "none";
}

function showUpholdSupportButton() {
  let upholdSupportButton = document.getElementById("go_to_uphold");
  upholdSupportButton.text = "Go to Uphold";
  upholdSupportButton.style.display = "inline !important";
}

function disconnectUphold() {
  submitForm("disconnect_uphold", "PATCH", true).then(function(response) {
    return checkUpholdStatus();
  });
}

function openDefaultCurrencyModal() {
  let template = document.querySelector(
    "#confirm_default_currency_modal_wrapper"
  );
  let closeFn = openModal(template.innerHTML);

  let form = document.getElementById("confirm_default_currency_form");

  // Sync default currency selected in modal with options and value from dashboard
  let upholdStatusElement = document.getElementById("uphold_status");
  let currentDefaultCurrency = upholdStatusElement.getAttribute(
    "data-default-currency"
  );
  let currencySelectInModal = document.getElementById(
    "publisher_default_currency"
  );
  populateCurrencySelect(
    currencySelectInModal,
    getPossibleCurrencies(),
    currentDefaultCurrency || ""
  );

  form.addEventListener(
    "submit",
    function(event) {
      event.preventDefault();

      let modal = document.getElementById("confirm_default_currency_modal");
      let status = document.querySelector(
        "#confirm_default_currency_modal .status"
      );

      if (!currencySelectInModal.value) {
        closeFn();
        return;
      }

      modal.classList.add("transitioning");

      submitForm("confirm_default_currency_form", "PATCH", false)
        .then(response => response.json())
        .then(body => {
          status.innerHTML = body.status;
          setTimeout(function() {
            if (body.action === "redirect") {
              window.location.href = body.redirectURL;
            } else if (body.action === "refresh") {
              refreshBalance().then(() => closeFn());
            } else {
              closeFn();
            }
          }, body.timeout);
        });
    },
    false
  );
}
window.openDefaultCurrencyModal = openDefaultCurrencyModal

function showWhatHappenedVerificationFailure() {
  let elementToReveal = this.nextSibling;
  elementToReveal.style.display = "block";
}

function hideVerificationFailureWhatHappened(element) {
  let elementToHide = element.nextSibling;
  elementToHide.style.display = "none";
}

function toggleDialog(event, elements) {
  for (var i = 0; i < elements.length; i++) {
    // Do not hide if the clicked element is supposed to show the bubble
    // Or if the clicked element is the bubble
    let e = elements[i];
    if (
      e === event.target ||
      e.nextSibling == event.target ||
      e.nextSibling.firstChild == event.target
    ) {
      continue;
    } else {
      hideVerificationFailureWhatHappened(e);
    }
  }
}

document.addEventListener("DOMContentLoaded", function() {
  if (document.querySelectorAll('body[data-action="home"]').length === 0) {
    return;
  }

  let upholdStatusElement = document.getElementById("uphold_status");

  if (upholdStatusElement.classList.contains("uphold-processing")) {
    checkUpholdStatusInterval = window.setInterval(checkUpholdStatus, 2000);
  } else if (
    upholdStatusElement.getAttribute(
      "data-open-confirm-default-currency-modal"
    ) === "true"
  ) {
    openDefaultCurrencyModal();
  }

  let removeChannelLinks = document.querySelectorAll("a.remove-channel");
  for (let i = 0, l = removeChannelLinks.length; i < l; i++) {
    removeChannelLinks[i].addEventListener(
      "click",
      function(event) {
        let channelId = event.target.getAttribute("data-channel-id");
        let template = document.querySelector(
          '[data-js-channel-removal-confirmation-template="' + channelId + '"]'
        );
        openModal(
          template.innerHTML,
          function() {
            removeChannel(channelId);
          },
          function() {}
        );
        event.preventDefault();
      },
      false
    );
  }

  let disconnectUpholdLink = document.querySelector("a.disconnect-uphold");
  if (disconnectUpholdLink) {
    disconnectUpholdLink.addEventListener(
      "click",
      function(event) {
        let template = document.querySelector('[id="disconnect-uphold-js"]');
        openModal(
          template.innerHTML,
          function() {
            disconnectUphold();
          },
          function() {}
        );
        event.preventDefault();
      },
      false
    );
  }

  let changeDefaultCurrencyLink = document.getElementById(
    "change_default_currency"
  );
  if (changeDefaultCurrencyLink) {
    changeDefaultCurrencyLink.addEventListener(
      "click",
      function(event) {
        openDefaultCurrencyModal();
        event.preventDefault();
      },
      false
    );
  }
  let verificationFailureWhatHappenedElements = document.getElementsByClassName(
    "verification-failed--what-happened"
  );

  for (let i = 0; i < verificationFailureWhatHappenedElements.length; i++) {
    verificationFailureWhatHappenedElements[i].addEventListener(
      "click",
      showWhatHappenedVerificationFailure,
      false
    );
  }

  let infoText = document.getElementsByClassName("info--what-happened");
  for (let i = 0; i < infoText.length; i++) {
    infoText[i].addEventListener(
      "click",
      showWhatHappenedVerificationFailure,
      false
    );
  }

  // Hide all verification failed bubbles when anywhere on DOM is clicked
  document.body.addEventListener("click", function(event) {
    toggleDialog(event, verificationFailureWhatHappenedElements);
    toggleDialog(event, infoText);
  });

  let instantDonationButton = document.getElementById(
    "instant-donation-button"
  );


  instantDonationButton.addEventListener(
    "click",
    async function(event) {
      document.getElementById("intro-container").style.padding = "50px";
      document.getElementsByClassName("modal-panel")[0].style.padding = "0px";
      document.getElementsByClassName("modal-panel--content")[0].style.padding =
        "0px";
      let preferredCurrency = document.getElementById("preferred_currency")
        .value;
      let conversionRate = document.getElementById("conversion_rate").value;

      let url = "/publishers/get_site_banner_data";

      let options = {
        method: "GET",
        credentials: "same-origin",
        headers: {
          Accept: "text/html",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": document.head.querySelector("[name=csrf-token]")
            .content
        }
      };

      let response = await fetch(url, options);
      if (response.status >= 400) {
        location.reload();
      }
      let bannerEditorData = await response.json();

      let defaultSiteBannerMode = bannerEditorData.default_site_banner_mode;
      let defaultSiteBanner = bannerEditorData.default_site_banner;
      let channelBanners = bannerEditorData.channel_banners;

      document.getElementById("open-banner-button").onclick = function() {
        renderBannerEditor(
          {},
          preferredCurrency,
          conversionRate,
          defaultSiteBannerMode,
          defaultSiteBanner,
          channelBanners,
          "Editor"
        );
      };

      document.getElementById("open-preview-button").onclick = function() {
        renderBannerEditor(
          {},
          preferredCurrency,
          conversionRate,
          defaultSiteBannerMode,
          defaultSiteBanner,
          channelBanners,
          "Preview"
        );
      };

      document.getElementsByClassName(
        "modal-panel--close js-deny"
      )[0].onclick = function(e) {
        document.getElementsByClassName("modal-panel")[0].style.maxWidth =
          "40rem";
        document.getElementsByClassName("modal-panel")[0].style.padding =
          "2rem 2rem";
        document.getElementsByClassName(
          "modal-panel--content"
        )[0].style.padding = "1rem 1rem 0 1rem";
      };
    },
    false
  );

});
