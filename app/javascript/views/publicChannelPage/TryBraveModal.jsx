import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import {
  TryBraveButton,
  TryBraveBackground,
  TryBraveHeader,
  TryBraveSubHeader,
  TryBraveBullet,
  TryBraveHeaderSection,
  TryBraveIcon,
  TryBraveText,
} from "./PublicChannelPageStyle.js";
import icon from "../../../assets/images/wallet_icon_color.png";
import orangeCheckmark from "../../../assets/images/orange_checkmark.png";


class TryBraveModal extends React.Component {
  constructor(props) {
    super(props);
  }
  
  render() {
    return (
      <TryBraveBackground>
        <TryBraveHeaderSection>
          <TryBraveIcon>
            <img src={icon}/>
          </TryBraveIcon>
          <div>
            <TryBraveHeader>
              <FormattedMessage id="publicChannelPage.tryBraveHeader" />
            </TryBraveHeader>
            <TryBraveSubHeader>
              <FormattedMessage id="publicChannelPage.tryBraveSubheader" />
            </TryBraveSubHeader>
          </div>
        </TryBraveHeaderSection>
        <TryBraveText>
          <FormattedMessage id="publicChannelPage.tryBraveText" />
        </TryBraveText>
        <TryBraveBullet>
          <img src={orangeCheckmark}/>
          <FormattedMessage id="publicChannelPage.tryBraveBullet1" />
        </TryBraveBullet>
        <TryBraveBullet>
          <img src={orangeCheckmark}/>
          <FormattedMessage id="publicChannelPage.tryBraveBullet2" />
        </TryBraveBullet>
        <TryBraveBullet>
          <img src={orangeCheckmark}/>
          <FormattedMessage id="publicChannelPage.tryBraveBullet3" />
        </TryBraveBullet>
        <TryBraveButton href="https://brave.com/wallet/" target="_blank">
          <FormattedMessage id="publicChannelPage.tryBraveButton" />
        </TryBraveButton>
      </TryBraveBackground>
    )
  }
}

export default injectIntl(TryBraveModal);
