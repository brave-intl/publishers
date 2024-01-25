import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import {
  QRTitle,
  QRText,
  QRTextItem,
  QRBox,
  QRSubTitle,
} from "./PublicChannelPageStyle.js";
import QRCodeStyling from "qr-code-styling";
import icon from "../../../assets/images/smartphone-laptop.svg";
import qr_logo from "../../../assets/images/qr_logo.png";

class QRCodeModal extends React.Component {
  constructor(props) {
    super(props);

    this.paymentUrl = props.address;
    this.chain = props.chain;
    this.displayChain = props.displayChain;
    this.fullChain = props.intl.formatMessage({id: `publicChannelPage.${this.chain}`});
  }

  componentDidMount() {
    this.createQRCode();
  }

  createQRCode() {
    const qrCode = new QRCodeStyling({
      width: 270,
      height: 270,
      data: this.paymentUrl,
      image: qr_logo,
      dotsOptions: {
        color: "#000000",
        type: "dots"
      },
      imageOptions: {
        crossOrigin: "anonymous",
        margin: 3
      },
      cornersSquareOptions: {
        type: 'extra-rounded'
      },
      cornersDotOptions: {
        type: 'square'
      }
    });

    qrCode.append(window.document.getElementById('qr-wrapper'))
  }
  
  render() {
    return (
      <div>
        <QRTitle>
          <FormattedMessage id="publicChannelPage.QRModalHeader" />
            {this.displayChain.includes('BAT') ? (
              <QRSubTitle><FormattedMessage id="publicChannelPage.QRBatText" values={{chain: this.fullChain}}/></QRSubTitle>
            ) : (
              <QRSubTitle><FormattedMessage id="publicChannelPage.QRStandardText" values={{chain: this.chain}}/></QRSubTitle>
            )}
        </QRTitle>
        <QRBox id="qr-wrapper" className="text-center" />
        <QRText>
          <QRTextItem>
            <img src={icon} className="pr-3"/>
          </QRTextItem>
          <QRTextItem>
            <FormattedMessage id="publicChannelPage.QRModalText" />
          </QRTextItem>
        </QRText>
      </div>
    )
  }
}

export default injectIntl(QRCodeModal);
