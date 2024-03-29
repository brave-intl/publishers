import axios from "axios";
import * as React from "react";
import * as ReactDOM from "react-dom";
import PublicChannelPage from "../views/publicChannelPage/PublicChannelPage";
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

  const element =  document.getElementsByClassName("public-channel-page")[0]
  const props = JSON.parse(element.dataset.props);
  ReactDOM.render(
    <IntlProvider locale={locale} messages={flattenMessages(localePackage)}>
      <PublicChannelPage {...props} />
    </IntlProvider>,
    element
  );
});
