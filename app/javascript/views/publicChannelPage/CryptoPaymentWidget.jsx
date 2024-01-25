// webpacker does not import the correct version automatically.
// this is necessary for the Solana transfer object to function
import * as buffer from "buffer";
window.Buffer = buffer.Buffer;
import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import Web3 from "web3";
import {
  Connection,
  Keypair,
  SystemProgram,
  LAMPORTS_PER_SOL,
  Transaction,
  sendAndConfirmTransaction,
  PublicKey,
} from "@solana/web3.js";
import {
  getAssociatedTokenAddress,
  createAssociatedTokenAccountInstruction,
  createTransferInstruction,
} from "@solana/spl-token";
import axios from "axios";
import Select, { components } from 'react-select';
import routes from "../routes";
import Modal, { ModalSize } from "../../components/modal/Modal";
import QRCodeModal from "./QRCodeModal";
import TryBraveModal from "./TryBraveModal";
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
  ErrorSection,
  ErrorIcon,
  ErrorText,
  ErrorMessage,
  ErrorTitle,
  CryptoOptionSubheading,
} from "./PublicChannelPageStyle.js";
import ethIcon from "../../../assets/images/eth_icon_larger.png";
import solIcon from "../../../assets/images/solana_icon_larger.png";
import batIcon from "../../../assets/images/bat_icon.png";
import warningIcon from "../../../assets/images/warning-circle-filled.png";
import batAbi from "./batAbi.json";

class CryptoPaymentWidget extends React.Component {
  constructor(props) {
    super(props);

    this.intl = props.intl;
    const placeholder = this.intl.formatMessage({id: 'publicChannelPage.custom'});
    const cryptoAddresses = props.cryptoAddresses;
    // There shouldn't be more than one of each, but just in case
    const solAddress = cryptoAddresses.filter(address => address.includes('SOL'))[0];
    const ethAddress = cryptoAddresses.filter(address => address.includes('ETH'))[0];

    const addresses = { SOL: solAddress && solAddress[0], ETH: ethAddress && ethAddress[0] };

    this.iconOptions = { SOL: solIcon, ETH: ethIcon, BAT: batIcon };

    const dropdownOptions = []

    if (ethAddress) {
      dropdownOptions.push({
        label: this.intl.formatMessage({ id: 'publicChannelPage.ethereumNetwork' }),
        options: [
          {
            label: this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.ethereum' }),
            subheading: this.intl.formatMessage({id: 'publicChannelPage.ethSubheading'}),
            value: "ETH", 
            icon: ethIcon
          },
          {
            label: this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.ethereumBAT' }),
            subheading: this.intl.formatMessage({id: 'publicChannelPage.ethBatSubheading'}),
            value: "BAT",
            icon: batIcon
          }
        ]
      })
    }

    if (solAddress) {
      dropdownOptions.push({
        label: this.intl.formatMessage({ id: 'publicChannelPage.solanaNetwork' }),
        options: [
          {
            label: this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.solana' }),
            subheading: this.intl.formatMessage({id: 'publicChannelPage.solSubheading'}),
            value: "SOL",
            icon: solIcon
          },
          {
            label: this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.solanaBAT' }),
            subheading: this.intl.formatMessage({id: 'publicChannelPage.solBatSubheading'}),
            value: "splBAT",
            icon: batIcon
          }
        ]
      })
    }

    const currentChain = ethAddress ? 'BAT' : 'splBAT';

    this.state = {
      ethBatAddress: props.cryptoConstants.eth_bat_address,
      solanaBatAddress: props.cryptoConstants.solana_bat_address,
      solanaMainUrl: props.cryptoConstants.solana_main_url,
      placeholder,
      isLoading: true,
      currentAmount: 5,
      addresses,
      dropdownOptions,
      // the channel must have at least one crypto address for this page to be navigable,
      // and right now the options are only sol and eth
      currentChain,
      displayChain: 'BAT',
      defaultAmounts: [1,5,10],
      isModalOpen: false,
      isTryBraveModalOpen: false,
      ratios: {},
      customAmount: null,
      toggle: 'crypto',
      selectValue: dropdownOptions.flatMap(opt => opt.options).filter(opt => opt.value === currentChain)[0],
      isSuccessView: false,
      title: this.props.title,
      errorTitle: null,
      errorMsg: null,
    }
  }

  componentDidMount() {
    this.loadData();

    // Set up a setInterval to fetch new price data every 5 minutes (300,000 milliseconds)
    this.intervalId = setInterval(this.backgroundLoadData.bind(this), 300000);
  }

  componentWillUnmount() {
    clearInterval(this.intervalId);
  }

  backgroundLoadData() {
    axios.get(routes.publishers.publicChannelPage.getRatios).then((response) => {
      const newState = { ...this.state }
      newState.ratios = response.data;
      this.setState({ ...newState });
    });
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
    return this.state.currentAmount / this.state.ratios[this.state.displayChain.toLowerCase()]['usd'];
  };

  roundCryptoPrice() {
    return Math.round(this.calculateCryptoPrice() * 100000) / 100000;
  };

  baseChain() {
    if (this.state.currentChain.includes('BAT')) {
      return this.state.currentChain === 'BAT' ? 'ETH' : 'SOL';
    } else {
      return this.state.currentChain;
    }
  };

  closeModal = () => {
    this.setState({ isModalOpen: false });
  };

  launchQRModal() {
    this.setState({ isModalOpen: true });
  };

  closeTryBraveModal = () => {
    this.setState({ isTryBraveModalOpen: false });
  };

  launchTryBraveModal = async () => {
    const newState = {...this.state};
    newState.isTryBraveModalOpen = true;
    this.setState({...newState });
  };

  sendPayment = async () => {
    this.clearError();
    if (this.state.currentChain === "ETH") {
      await this.sendEthPayment();
    } else if (this.state.currentChain === "SOL") {
      this.sendSolPayment();
    } else if (this.state.currentChain === "BAT") {
      this.sendEthBatPayment();
    } else if (this.state.currentChain === "splBAT") {
      this.sendSolBatPayment();
    }
  };

  setGenericError() {
    const newState = {...this.state};
    newState.errorTitle = this.intl.formatMessage({id: 'publicChannelPage.ErrorTitle'});
    newState.errorMsg = this.intl.formatMessage({id: 'publicChannelPage.ErrorMsg'});
    this.setState({...newState });
  };

  setError(titleId, msgId) {
    const newState = {...this.state};
    newState.errorTitle = this.intl.formatMessage({id: titleId});
    newState.errorMsg = this.intl.formatMessage({id: msgId});
    this.setState({...newState });
  }

  clearError() {
    const newState = {...this.state};
    newState.errorTitle = null;
    newState.errorMsg = null;
    this.setState({...newState });
  }

  sendEthPayment = async () => {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      const address = accounts[0]
      if (!address) {
        this.setGenericError();
        return;
      }

      // While most guides to converting eth to wei multiply the value by 10e18, In javascript e counts 
      // as the 10 and *10e18 results in a value that is an order of mangitude too high.
      const value = Web3.utils.toHex(Web3.utils.toBigInt(Math.round(this.calculateCryptoPrice()*10e17)));

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
          const newState = {...this.state};
          newState.isSuccessView = true;
          this.setState({...newState });
        })
        .catch((error) => {
          this.setGenericError();
        });
    } else {
      await this.launchTryBraveModal();
      this.setError('publicChannelPage.noEthTitle', 'publicChannelPage.noEthMsg')
      return;
    }
  }

  sendEthBatPayment = async () => {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      const address = accounts[0]
      if (!address) {
        this.setGenericError();
        return;
      }

      try {
        const web3 = new Web3(window.ethereum);
        const batContractAddress = this.state.ethBatAddress;

        const contract = new web3.eth.Contract(batAbi, batContractAddress);
        const amount = Web3.utils.toBigInt(Math.round(this.calculateCryptoPrice()*10e17))
        const encodedAbi = await contract.methods.transfer(this.state.addresses.ETH, amount).encodeABI()

        const results = await web3.eth.sendTransaction({
                          from: address,
                          to: batContractAddress,
                          value: "0",  // note that value is a string
                          data: encodedAbi,
                        })
        
        if (results.status > 0) {
          const newState = {...this.state};
          newState.isSuccessView = true;
          this.setState({...newState });
        }
      } catch (e) {
        this.setGenericError();
        return;
      }
    } else {
      await this.launchTryBraveModal();
      this.setError('publicChannelPage.noEthTitle', 'publicChannelPage.noEthMsg');
      return;
    }
  }

  sendSolPayment = async () => {
    if (!window.solana) {
      await this.launchTryBraveModal();
      this.setError('publicChannelPage.noSolTitle', 'publicChannelPage.noSolMsg');
      return;
    }

    const provider = await window.solana.connect();
    if (provider.publicKey) {
      const pub_key = provider.publicKey
      const connection = new Connection(this.state.solanaMainUrl);
      const amount = Math.round(this.calculateCryptoPrice() * LAMPORTS_PER_SOL)
      
      const transaction = new Transaction().add(
        SystemProgram.transfer({
          fromPubkey: pub_key,
          toPubkey: this.state.addresses.SOL,
          lamports: amount,
        })
      );
      transaction.feePayer = pub_key;
      const blockhashObj = await connection.getLatestBlockhash('confirmed');
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
        this.setGenericError();
        window.solana.disconnect()
      }
    } else {
      this.setGenericError();
      return;
    }
  }

  sendSolBatPayment = async () => {
    if (!window.solana) {
      await this.launchTryBraveModal();
      this.setError('publicChannelPage.noSolTitle', 'publicChannelPage.noSolMsg');
      return;
    }
    const provider = await window.solana.connect();
    
    if (provider.publicKey) {
      try {
        // This is the account address of the user who is sending bat
        const sourceAccountOwner = provider.publicKey
        // this is the address of the BAT program on the solana chain
        const batAddress = new PublicKey(this.state.solanaBatAddress);
        // multiply the number of bat tokens to the power of the decimals in the token program 
        const amount = Math.round(this.calculateCryptoPrice() * Math.pow(10, 8));
        // this is the account address that will receive bat
        const destinationAccountOwner = new PublicKey(this.state.addresses.SOL)
        
        const connection = new Connection(this.state.solanaMainUrl)

        // Check to see if the sender has an associated token account
        const senderAccount = await connection.getParsedTokenAccountsByOwner(sourceAccountOwner, {
          mint: batAddress,
        });

        if (senderAccount.value.length > 0) {
          const senderTokenAddress = senderAccount.value[0].pubkey;

          // get receiver associated token account
          const destinationAccount = await connection.getParsedTokenAccountsByOwner(destinationAccountOwner, {
            mint: batAddress,
          });
          // Does the receiver token account already exist?
          const hasDestinationAccount = destinationAccount.value.length > 0;

          // Get the receiver token address, whether it exists or not
          const destinationTokenAddress = hasDestinationAccount ? destinationAccount.value[0].pubkey : await getAssociatedTokenAddress(batAddress, destinationAccountOwner);

          const tx = new Transaction();
          
          // if the token accout has not been created, add an instruction to create it
          if (!hasDestinationAccount) {
            tx.add(createAssociatedTokenAccountInstruction(
              sourceAccountOwner,
              destinationTokenAddress,
              destinationAccountOwner,
              batAddress,
            ))
          }
          // Add the instruction to transfer the tokens
          tx.add(createTransferInstruction(
            senderTokenAddress,
            destinationTokenAddress,
            sourceAccountOwner,
            amount
          ));

          const latestBlockHash = await connection.getLatestBlockhash('confirmed');
          tx.recentBlockhash = await latestBlockHash.blockhash;
          tx.feePayer = sourceAccountOwner;
          
          const signature = await window.solana.signAndSendTransaction(tx);
          if ( signature.signature ) {
            window.solana.disconnect();
            const newState = {...this.state};
            newState.isSuccessView = true;
            this.setState({...newState });
          }
        } else {
          this.setError('publicChannelPage.ErrorTitle', 'publicChannelPage.insufficientBalance');
          window.solana.disconnect();
          return;
        }
      } catch (e) {
        this.setGenericError();
        window.solana.disconnect()
      }
    } else {
      this.setGenericError();
      return;
    }
  }

  changeChain(optionVal){
    const newState = {...this.state};
    newState.currentChain = optionVal.value;
    newState.selectValue = optionVal;
    newState.displayChain = optionVal.value.includes("BAT") ? 'BAT' : optionVal.value;
    newState.errorTitle = null;
    newState.errorMsg = null;
    this.setState({...newState });
  }

  handleButtonClick = (value) => {
    const newState = {...this.state};
    newState.currentAmount = value;
    this.setState({...newState });
  };
  
  handleInputChange = (event) => {
    const customValue = event.target.value ? parseFloat(event.target.value) : null;
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
      return ( <SuccessWidget setStateToStart={this.setStateToStart.bind(this)} amount={this.roundCryptoPrice()} chain={this.state.displayChain} name={this.state.title} /> )
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
                  SingleValue: ({ children, ...rest }) => (
                    <components.SingleValue {...rest}>
                      {children}
                      <CryptoOptionSubheading>{rest.data.subheading}</CryptoOptionSubheading>
                    </components.SingleValue>
                  ),
                  Option: CryptoPaymentOption
                }}
                value={this.state.selectValue}
                styles={{
                  control: (base) => ({ ...base,
                    boxShadow: 'none',
                    borderColor: 'rgba(161, 178, 186, 0.4)',
                    padding: '0px 16px',
                    borderRadius: '8px'
                  }),
                  groupHeading: (base) => ({...base,
                    textAlign: 'left',
                    fontSize: '11px',
                    backgroundColor: 'rgba(243, 245, 247, 1)',
                    padding: '12px 16px',
                  }),
                  group: (base) => ({...base, padding: '0px'}),
                  indicatorSeparator: (base) => ({...base, display: 'none'}),
                  dropdownIndicator: (base) => ({...base,
                    padding: '0px',
                    color: 'rgba(98, 117, 126, 1)',
                  }),
                  input: (base) => ({...base, caretColor: 'transparent' }),
                  valueContainer: (base) => ({ ...base,
                    display: 'flex',
                    textAlign: 'left',
                    padding: '16px',
                    fontWeight: '600',
                    paddingLeft: '50px',
                    backgroundImage: `url(${this.iconOptions[this.state.displayChain]})`,
                    backgroundRepeat: 'no-repeat',
                    backgroundPosition: 'left',
                    backgroundSize: "40px",
                  }),
                  menu: (base) => ({
                    ...base,
                    marginTop: '0px',
                    borderRadius: '8px',
                    boxShadow: '0px 4px 16px -2px rgba(0, 0, 0, 0.1), 0px 1px 0px 0px rgba(0, 0, 0, 0.05)',
                    overflow: 'hidden',
                  }),
                  menuList: (base) => ({
                    ...base,
                    maxHeight: '500px',
                    paddingTop: '0px',
                  }),
                }}
              />
            <div className="row no-gutters pb-4 pt-4">
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
                      <span>{this.roundCryptoPrice()} <span className="currency align-middle">{this.state.displayChain}</span></span>
                    ) : (
                      <span>${this.state.currentAmount} <span className="currency align-middle">USD</span></span>
                    )}
                </LargeCurrencyDisplay>
                <SmallCurrencyDisplay>
                  {this.state.toggle === 'fiat' ? (
                      <span>{this.roundCryptoPrice()} {this.state.displayChain}</span>
                    ) : (
                      <span>${this.state.currentAmount} USD</span>
                    )}
                </SmallCurrencyDisplay>
                <ExchangeIcon onClick={this.toggleCurrency.bind(this)} />
              </div>
            </div>
            {this.state.errorTitle && (
              <ErrorSection>
                <ErrorIcon><img src={warningIcon}/></ErrorIcon>
                <ErrorText>
                  <ErrorTitle>{this.state.errorTitle}</ErrorTitle>
                  <ErrorMessage>{this.state.errorMsg}</ErrorMessage>
                </ErrorText>
              </ErrorSection>
            )}
          </PaymentOptions>
          <PaymentButtons>
            <SendButton onClick={(event) => {
                event.preventDefault();
                this.sendPayment();
              }}
              disabled={this.state.currentAmount <= 0}
            >
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
            size={ModalSize.QrCustom}
            handleClose={() => this.closeModal()}
          >
            <QRCodeModal
              address={this.state.addresses[this.baseChain()]}
              chain={this.baseChain()}
              displayChain={this.state.displayChain}
            />
          </Modal>
          <Modal
            show={this.state.isTryBraveModalOpen}
            size={ModalSize.ExtraExtraSmall}
            padding={false}
            handleClose={() => this.closeTryBraveModal()}
          >
            <TryBraveModal />
          </Modal>
        </CryptoWidgetWrapper>
      )
    }
  }
}

export default injectIntl(CryptoPaymentWidget);
