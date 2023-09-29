import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import {
  QRTitle,
  QRText,
  QRTextItem,
  QRBox,
} from "./PublicChannelPageStyle.js";
import QRCodeStyling from "qr-code-styling";
import icon from "../../../assets/images/smartphone-laptop.png";
import qr_logo from "../../../assets/images/qr_logo.png";

class QRCodeModal extends React.Component {
  constructor(props) {
    super(props);
    console.log(props)

    const paymentAmount = props.amount / props.ratios[props.chain.toLowerCase()]['usd']

    if (props.chain === 'ETH') {
      this.paymentUrl = `ethereum:${props.address}?value=${paymentAmount}`;
    } else if (props.chain === 'SOL') {
      this.paymentUrl = props.address;
    }
  }

  componentDidMount() {
    this.createQRCode();
  }

  createQRCode() {
    const qrCode = new QRCodeStyling({
      width: 300,
      height: 300,
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
        <QRTitle><FormattedMessage id="publicChannelPage.QRModalHeader" /></QRTitle>
        <QRBox id="qr-wrapper" className="text-center" />
        <QRText>
          <QRTextItem>
            <img src={icon} className="pr-2"/>
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
