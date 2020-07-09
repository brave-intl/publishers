import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";

import Modal, { ModalSize } from "../../../../components/modal/Modal";
import { FlexWrapper } from "../../../style";
import { UpholdStatus } from "../UpholdConnection";
import DisconnectPrompt from "./UpholdDisconnectPrompt";

const UpholdStatusMessage = (props) => {
  if (props.status === UpholdStatus.Verified) {
    return <React.Fragment />;
  }
  let messageId = "";
  console.log('props.status', props.status)

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
    <div className="my-2 text-danger">
      <FormattedMessage id={messageId} />
    </div>
  );
};

export default injectIntl(UpholdStatusMessage);
