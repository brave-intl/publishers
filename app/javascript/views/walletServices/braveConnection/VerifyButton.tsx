import * as React from "react";
import { FormattedMessage } from "react-intl";
import warning from "./verifyButton/warning.png";

export const VerifyButton = (props) => (
  <div className="alert alert-warning align-items-center m-0">
    <div className="d-flex align-items-center">
      <img className="mr-3" width="28" height="28" src={warning} />

      <div className="row align-items-center">
        <small className="col-sm-8">{props.children}</small>
        {props.verifyUrl && (
          <small className="col-sm-4">
            <a
              className="font-weight-bold"
              target="_blank"
              rel="noopener noreferrer"
              href={props.verifyUrl}
            >
              <FormattedMessage id={"walletServices.verify"} />
            </a>
          </small>
        )}
      </div>
    </div>
  </div>
);
