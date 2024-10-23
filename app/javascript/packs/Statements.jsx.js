import * as React from "react";
import * as ReactDOM from "react-dom";
import Statements from "../views/statements/Statements";

import { IntlProvider } from "react-intl";
import en, { flattenMessages } from "../locale/en";

document.addEventListener("DOMContentLoaded", () => {
  let localePackage = en;

  ReactDOM.render(
    <IntlProvider
      locale={document.body.dataset.locale}
      messages={flattenMessages(localePackage)}
    >
      <Statements />
    </IntlProvider>,
    document.getElementsByClassName("statements")[0],
  );
});
