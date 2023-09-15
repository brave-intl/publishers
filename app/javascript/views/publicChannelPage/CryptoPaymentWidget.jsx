// webpacker does not import the correct version automatically.
// this is necessary for the Solana transfer object to function
import * as buffer from "buffer";
window.Buffer = buffer.Buffer;
import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import * as Web3Utils from "web3-utils";
import {
  Connection,
  Keypair,
  SystemProgram,
  LAMPORTS_PER_SOL,
  Transaction,
  sendAndConfirmTransaction,
} from "@solana/web3.js";
import axios from "axios";
import Select from 'react-select';
import routes from "../routes";
import Modal, { ModalSize } from "../../components/modal/Modal";
import QRCodeModal from "./QRCodeModal";
import CryptoPaymentOption from "./CryptoPaymentOption";
import SuccessWidget from "./SuccessWidget";
import {
  CryptoWidgetWrapper,
  QRLink,
  WidgetSubHeading,
  WidgetHeading,
  HeadingWrapper,
  SendButton,
  PaymentButtons,
  PaymentOptions,
  LargeCurrencyDisplay,
  SmallCurrencyDisplay,
  ExchangeIcon,
  AmountButton,
  AmountInput,
} from "./PublicChannelPageStyle.js";
import ethIcon from "../../../assets/images/eth_icon_larger.png";
import solIcon from "../../../assets/images/solana_icon_larger.png";



class CryptoPaymentWidget extends React.Component {
  constructor(props) {
    super(props);

    const intl = props.intl;
    const placeholder = intl.formatMessage({id: 'publicChannelPage.custom'});
    const cryptoAddresses = props.cryptoAddresses;
    // There shouldn't be more than one of each, but just in case
    const solAddress = cryptoAddresses.filter(address => address.includes('SOL'))[0];
    const ethAddress = cryptoAddresses.filter(address => address.includes('ETH'))[0];

    const addresses = { SOL: solAddress && solAddress[0], ETH: ethAddress && ethAddress[0] };

    const dropdownOptions = []

    if (ethAddress) {
      dropdownOptions.push({
        label: intl.formatMessage({ id: 'publicChannelPage.ethereumNetwork' }),
        options: [
          { label: intl.formatMessage({ id: 'walletServices.addCryptoWidget.ethereum' }), value: "ETH", icon: ethIcon },
        ]
      })
    }

    if (solAddress) {
      dropdownOptions.push({
        label: intl.formatMessage({ id: 'publicChannelPage.solanaNetwork' }),
        options: [
          { label: intl.formatMessage({ id: 'walletServices.addCryptoWidget.solana' }), value: "SOL", icon: solIcon },
        ]
      })
    }

    const currentChain = ethAddress ? 'ETH' : 'SOL';

    this.state = {
      placeholder,
      isLoading: true,
      currentAmount: 5,
      addresses,
      dropdownOptions,
      // the channel must have at least one crypto address for this page to be navigable,
      // and right now the options are only sol and eth
      currentChain,
      defaultAmounts: [1,5,10],
      isModalOpen: false,
      ratios: {},
      customAmount: null,
      toggle: 'crypto',
      selectValue: dropdownOptions.flatMap(opt => opt.options).filter(opt => opt.value === currentChain)[0],
      isSuccessView: false,
    }
  }

  componentDidMount() {
    this.loadData();
  }

  loadData = () => {
    this.setState({ isLoading: true });
    axios.get(routes.publishers.publicChannelPage.getRatios).then((response) => {
      const newState = { ...this.state }
      newState.isLoading = false;
      newState.ratios = response.data;
      this.setState({ ...newState });
    });
  };

  calculateCryptoPrice() {
    return this.state.currentAmount / this.state.ratios[this.state.currentChain.toLowerCase()]['usd'];
  }

  roundCryptoPrice() {
    return Math.round(this.calculateCryptoPrice() * 100000) / 100000;
  }

  closeModal = () => {
    this.setState({ isModalOpen: false });
  }

  launchQRModal() {
    this.setState({ isModalOpen: true });
  }

  sendPayment = async () => {
    if (this.state.currentChain === "ETH") {
      await this.sendEthPayment();
    } else if (this.state.currentChain === "SOL") {
      this.sendSolPayment();
    }
  }

  sendEthPayment = async () => {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      const address = accounts[0]
      if (!address) {
        // set to be designed error state here
        return;
      }

      // While most guides to converting eth to wei multiply the value by 10e18, In javascript e counts 
      // as the 10 and *10e18 results in a value that is an order of mangitude too high.
      const value = Web3Utils.toHex(Web3Utils.toBigInt(Math.round(this.calculateCryptoPrice()*10e17)));

      const params = [{
        from: address,
        to: this.state.addresses.ETH,
        value: value
      }];

      const transaction = window.ethereum
        .request({
          method: 'eth_sendTransaction',
          params,
        })
        .then((result) => {
          // window.ethereum.disable()
          const newState = {...this.state};
          newState.isSuccessView = true;
          this.setState({...newState });
        })
        .catch((error) => {
          console.log(error)
          // window.ethereum.disable()
          // set to be designed error state here
        });
    } else {
      // set to be designed error state here
      return;
    }
  }

  sendSolPayment = async () => {
    if (!window.solana) {
      // set to be designed error state here
      return false;
    }

    const provider = await window.solana.connect();
    if (provider.publicKey) {
      const pub_key = provider.publicKey
      
      const NETWORK = 'https://api.testnet.solana.com/';
      const connection = new Connection(NETWORK);
      const amount = Math.round(this.calculateCryptoPrice() * LAMPORTS_PER_SOL)
      
      const transaction = new Transaction().add(
        SystemProgram.transfer({
          fromPubkey: pub_key,
          toPubkey: this.state.addresses.SOL,
          lamports: amount,
        })
      );
      transaction.feePayer = pub_key;
      let blockhashObj = await connection.getRecentBlockhash();
      transaction.recentBlockhash = await blockhashObj.blockhash;

      try {
        const result = await window.solana.signAndSendTransaction(transaction);
        if ( result.signature ) {
          window.solana.disconnect();
          const newState = {...this.state};
          newState.isSuccessView = true;
          this.setState({...newState });
        }
      } catch (e) {
        console.log(e)
        // set to be designed error state here
        window.solana.disconnect()
      }
    } else {
      // set to be designed error state here
      return;
    }
  }

  changeChain(optionVal){
    const newState = {...this.state};
    newState.currentChain = optionVal.value;
    newState.selectValue = optionVal;
    this.setState({...newState });
  }

  handleButtonClick = (value) => {
    const newState = {...this.state};
    newState.currentAmount = value;
    this.setState({...newState });
  };
  
  handleInputChange = (event) => {
    const customValue = parseFloat(event.target.value);
    const newState = {...this.state};
    newState.customAmount = customValue;
    newState.currentAmount = customValue;
    this.setState({...newState });
  };

  toggleCurrency() {
    const newState = {...this.state};
    newState.toggle = this.state.toggle === 'crypto' ? 'fiat' : 'crypto'
    this.setState({...newState });
  }

  setStateToStart() {
    const newState = {...this.state};
    newState.isSuccessView = false;
    this.setState({...newState });
  }
  
  render() {
    if (this.state.isLoading) {
      return (<CryptoWidgetWrapper></ CryptoWidgetWrapper>)
    } else if (this.state.isSuccessView) {
      return ( <SuccessWidget setStateToStart={this.setStateToStart.bind(this)} amount={this.roundCryptoPrice()} chain={this.state.currentChain} /> )
    } else {
      return (
        <CryptoWidgetWrapper>
          <HeadingWrapper>
            <WidgetSubHeading>
              <FormattedMessage id="publicChannelPage.paymentSubHeading" />
            </WidgetSubHeading>
            <WidgetHeading>
              <FormattedMessage id="publicChannelPage.paymentHeading" />
            </WidgetHeading>
          </HeadingWrapper>
          <PaymentOptions>
            <Select
                options={this.state.dropdownOptions}
                onChange={this.changeChain.bind(this)}
                components={{
                  Option: CryptoPaymentOption,
                }}
                value={this.state.selectValue}
                styles={{
                  IndicatorSeparator: (base) => ({ ...base, background: '#ffffff' }),
                  Control: (base) => ({ ...base, border: 'none' }),
                  ValueContainer: (base) => ({
                    ...base,
                    textAlign: 'left',
                    padding: '26px',
                    fontWeight: '600',
                  }),
                }}
              />
            <div className="row no-gutters pt-4">
              <div className="col-xs-12 col-md-7 text-left">
                {this.state.defaultAmounts.map( amount => {
                  return(
                    <AmountButton
                      key={amount}
                      className={this.state.currentAmount === amount ? 'selected' : ''}
                      onClick={() => this.handleButtonClick(amount)}
                    >
                      ${amount}
                    </AmountButton>
                  )
                })}
                <AmountInput
                  type="number"
                  onChange={this.handleInputChange}
                  className={this.state.currentAmount === this.state.customAmount ? 'selected' : ''}
                  placeholder={this.state.placeholder}
                  value={this.state.customAmount}
                />
              </div>
              <div className="col-xs-12 col-md-5 text-right align-top">
                <LargeCurrencyDisplay>
                  {this.state.toggle === 'crypto' ? (
                      <span>{this.roundCryptoPrice()} <span className="currency align-middle">{this.state.currentChain}</span></span>
                    ) : (
                      <span>${this.state.currentAmount} <span className="currency align-middle">USD</span></span>
                    )}
                </LargeCurrencyDisplay>
                <SmallCurrencyDisplay>
                  {this.state.toggle === 'fiat' ? (
                      <span>{this.roundCryptoPrice()} {this.state.currentChain}</span>
                    ) : (
                      <span>${this.state.currentAmount} USD</span>
                    )}
                </SmallCurrencyDisplay>
                <ExchangeIcon onClick={this.toggleCurrency.bind(this)} />
              </div>
            </div>
          </PaymentOptions>
          <PaymentButtons>
            <SendButton onClick={(event) => {
              event.preventDefault();
              this.sendPayment();
            }}>
              <FormattedMessage id="publicChannelPage.send" />
            </SendButton>
            
            <QRLink onClick={(event) => {
              event.preventDefault();
              this.launchQRModal();
            }}>
              <FormattedMessage id="publicChannelPage.generateQR" />
            </QRLink>
          </PaymentButtons>
          <Modal
            show={this.state.isModalOpen}
            size={ModalSize.ExtraSmall}
            handleClose={() => this.closeModal()}
          >
            <QRCodeModal
              address={this.state.addresses[this.state.currentChain]}
              chain={this.state.currentChain}
              amount={this.state.currentAmount}
              ratios={this.state.ratios}
            />
          </Modal>
        </CryptoWidgetWrapper>
      )
    }
  }
}

export default injectIntl(CryptoPaymentWidget);
