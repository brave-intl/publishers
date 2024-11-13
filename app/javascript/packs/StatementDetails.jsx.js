import * as React from "react";
import * as ReactDOM from "react-dom";
import StatementDetails from "../views/statements/statements/StatementDetails";

import { IntlProvider } from "react-intl";
import en, { flattenMessages } from "../locale/en";

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector("#statement_details");
  const statement = JSON.parse(element.dataset.statement);
  let localePackage = en;

  ReactDOM.render(
    <IntlProvider
      locale={document.body.dataset.locale}
      messages={flattenMessages(localePackage)}
    >
      <StatementDetails statement={statement} showPage={true} />
    </IntlProvider>,
    document.getElementById("statement_details"),
  );
});
