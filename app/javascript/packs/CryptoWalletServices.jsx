import axios from "axios";
import * as React from "react";
import * as ReactDOM from "react-dom";
import CryptoWalletServices from "../views/cryptoWalletServices/CryptoWalletServices";
import { IntlProvider } from "react-intl";
import en, { flattenMessages } from "../locale/en";
import ja from "../locale/ja";

document.addEventListener("DOMContentLoaded", () => {
  const crsfToken = document.head
    .querySelector("[name=csrf-token]")
    .getAttribute("content");
  axios.defaults.headers.Accept = "application/json";
  axios.defaults.headers["X-CSRF-Token"] = crsfToken;

  const locale = document.body.dataset.locale;
  let localePackage = en;
  if (locale === "ja") {
    localePackage = ja;
  }

  const channels = document.querySelectorAll(".crypto-wallet-services")

  channels.forEach((channel) => {
    const channelId = channel.dataset.channelId;
    const props = JSON.parse(channel.dataset.props);
    
    ReactDOM.render(
      <IntlProvider locale={locale} messages={flattenMessages(localePackage)}>
        <CryptoWalletServices {...props} />
      </IntlProvider>,
      channel
    );
  });
});
