import { fetchAfterDelay, submitForm } from "../utils/request";
import "babel-polyfill";
import fetch from "../utils/fetchPolyfill";
import flash from "../utils/flash";
import { Wallet } from "../wallet";
import { formatFullDate } from "../utils/dates";
import { renderBannerEditor } from "../packs/banner_editor";

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
            .content,
        },
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
