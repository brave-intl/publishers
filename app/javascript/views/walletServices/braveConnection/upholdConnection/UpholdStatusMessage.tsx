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
  BlockedCountry = "blocked_country",
}

const UpholdStatusMessage = (props) => {
  if (props.status === UpholdStatus.Verified) {
    return <React.Fragment />;
  }

  let messageId = "";
  let url = props.verifyUrl;

  switch (props.status) {

    case UpholdStatus.CodeAcquired:
    case UpholdStatus.AccessParametersAcquired:
      messageId = "walletServices.uphold.status.connecting";
      break;
    case UpholdStatus.ReauthorizationNeeded:
      messageId = "walletServices.uphold.status.reauthorizationNeeded";
      url = null
      break;
    case UpholdStatus.Restricted:
      messageId = "walletServices.uphold.status.nonMember";
      if (props.uphold_is_member) {
        messageId = "walletServices.uphold.status.restrictedMember";
      }
      break;
    case UpholdStatus.BlockedCountry:
      messageId = "walletServices.uphold.status.blocked_country";
      break;
  }

  return (
    <div className="mt-2 text-danger">
      <VerifyButton verifyUrl={url}>
        <FormattedMessage id={messageId} values={{
          blocked_country_link: msg => (
            <a target='_blank' href='https://support.brave.com/hc/en-us/articles/6539887971469'>
              {msg}
            </a>
          )
        }} />
      </VerifyButton>
    </div>
  );
};

export default injectIntl(UpholdStatusMessage);
