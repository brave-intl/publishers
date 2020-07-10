import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import { VerifyButton } from "../VerifyButton";

enum UpholdStatus {
  ReauthorizationNeeded = "reauthorization_needed",
  Incomplete = "incomplete",
  Verified = "verified",
  AccessParametersAcquired = "access_parameters_acquired ",
  CodeAcquired = "code_acquired",
  Unconnected = "unconnected",
  Restricted = "restricted",
}

const UpholdStatusMessage = (props) => {
  if (props.status === UpholdStatus.Verified) {
    return <React.Fragment />;
  }
  let messageId = "";

  switch (props.status) {
    case UpholdStatus.CodeAcquired:
    case UpholdStatus.AccessParametersAcquired:
      messageId = "walletServices.uphold.status.connecting";
      break;
    case UpholdStatus.ReauthorizationNeeded:
      messageId = "walletServices.uphold.status.reauthorizationNeeded";
      break;
    case UpholdStatus.Restricted:
      messageId = "walletServices.uphold.status.nonMember";
      if (props.uphold_is_member) {
        messageId = "walletServices.uphold.status.restrictedMember";
      }
      break;
  }

  return (
    <div className="mt-2 mb-4 text-danger">
      <VerifyButton verifyUrl={props.verifyUrl}>
        <FormattedMessage id={messageId} />
      </VerifyButton>
    </div>
  );
};

export default injectIntl(UpholdStatusMessage);
