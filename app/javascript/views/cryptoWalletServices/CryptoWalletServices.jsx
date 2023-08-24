import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import ErrorBoundary from "../../components/errorBoundary/ErrorBoundary";
import CryptoWalletOption from './CryptoWalletOption'
import Select from 'react-select'
import axios from "axios";
import routes from "../routes";
import bs58 from 'bs58'

class CryptoWalletServices extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.intl = props.intl;
    
    this.state = {
      solOptions: [],
      ethOptions: [],
      currentSolAddress: null,
      currentEthAddress: null,
      isLoading: true,
      errorText: null,
    };
  }

  componentDidMount() {
    this.loadData();
  }

  // Helper functions
  formatOptionData(response, chain) {
    const options = response.data.filter( address => address.chain === chain)
                      .map( address => { return { value: address, label: address.address}})
    options.push({label: 'Add new wallet', value: {newAddress: chain}});
    return options;
  }

  findCurrentAddress(chain, channelResponse, allResponse) {
    const current = channelResponse.data.filter( address => address.chain === chain)[0]
    if (current) {
      const found = allResponse.data.filter( address => address.chain === chain )
        .find( address => address.id === current.crypto_address_id)
      return found ? { label: this.formatCryptoAddress(found.address), value: found } : null
    }
    return null;
  }

  formatCryptoAddress(address) {
    return `${address.slice(0,6)}****${address.slice(-4)}`;
  }

  // setup the dropdowns
  loadData = () => {
    this.setState({ isLoading: true });
    axios.get(routes.publishers.cryptoAddresses.index).then((response) => {
      const newState = {
        isLoading: false,
        errorText: null,
      };
      newState.solOptions = this.formatOptionData(response, 'SOL')
      newState.ethOptions = this.formatOptionData(response, 'ETH')
      
      axios.get(routes.publishers.cryptoAddressForChannels.index.replace('{channel_id}', this.channel.id)).then((channelResponse) => {
        newState.currentSolAddress = this.findCurrentAddress('SOL', channelResponse, response)
        newState.currentEthAddress = this.findCurrentAddress('ETH', channelResponse, response)

        this.setState({ ...newState });
      });
    });
  };

  // crypto connection functions

  getNonce = async () => {
    return axios.get(routes.publishers.cryptoAddressForChannels.generateNonce.replace('{channel_id}', this.channel.id)).then((response) => {
      return response.data.nonce;
    })
  }

  connectSolanaAddress = async () => {
    if (!window.solana) {
      this.setErrorText(this.intl.formatMessage('walletServices.addCryptoWidgetsolanaConnectError'));
      return false;
    }

    const results = await window.solana.connect();
    if (results.publicKey) {
      const pub_key = results.publicKey

      const possibleMatch = this.state.solOptions.filter(sol => sol.value.address === pub_key);
      if (possibleMatch.length > 0) {
        this.updateAddress(possibleMatch[0]);
        return;
      }

      const nonce = await this.getNonce();
      if (!nonce) {
        this.setErrorText(this.intl.formatMessage('walletServices.addCryptoWidgetgenericError'))
        return;
      }
      const encodedMessage = new TextEncoder().encode(nonce)
      let signedMessage = null

      try {
        signedMessage = await window.solana.signMessage(encodedMessage, "utf8")
      } catch (err) {
        this.setErrorText(this.intl.formatMessage('walletServices.addCryptoWidgetsolanaConnectionFailure'))
        return;
      }

      axios({
        method: 'post',
        url: routes.publishers.cryptoAddressForChannels.create.replace('{channel_id}', this.channel.id),
        data: {
          chain: 'SOL',
          account_address: pub_key,
          message: nonce,
          transaction_signature: bs58.encode(signedMessage.signature),
        }
      }).then((response) => {
        this.handleConnectionResponse(response)
      });
    }
  }

  connectEthereumAddress = async () => {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
      const address = accounts[0]
      if (!address) {
        this.setErrorText(this.intl.formatMessage('walletServices.addCryptoWidgetethereumConnectError'));
        return;
      }

      const possibleMatch = this.state.ethOptions.filter(eth => eth.value.address && eth.value.address.toLowerCase() === address.toLowerCase());
      if (possibleMatch.length > 0) {
        this.updateAddress(possibleMatch[0]);
        return;
      }

      const nonce = await this.getNonce();
      if (!nonce) {
        this.setErrorText(this.intl.formatMessage('walletServices.addCryptoWidget.genericError'))
        return;
      }

      const signature = await window.ethereum.request({
        method: 'personal_sign',
        params: [address, nonce]
      })
      console.log(nonce)
      axios({
        method: 'post',
        url: routes.publishers.cryptoAddressForChannels.create.replace('{channel_id}', this.channel.id),
        data: {
          chain: 'ETH',
          account_address: address,
          transaction_signature: signature,
          message: nonce
        }
      }).then((response) => {
        this.handleConnectionResponse(response)
      });
    } else {
      this.setErrorText(this.intl.formatMessage('walletServices.addCryptoWidget.ethereumConnectError'));
      return;
    }
  }

  // UI helpers for api responses
  handleConnectionResponse = (response) => {
    if (response.status < 300) {
      this.loadData();
    } else {
      setErrorText(this.intl.formatMessage('walletServices.addCryptoWidget.addressConnectFailure'))
    }
  }

  setErrorText(text) {
    const newState = {...this.state};
    newState.errorText = text;
    this.setState({...newState });
  }

  // Crud functions
  async changeAddress(optionValue) {
    const address = optionValue.value;
    if (address.newAddress === 'SOL') {
      await this.connectSolanaAddress();
    } else if (address.newAddress === 'ETH') {
      await this.connectEthereumAddress();
    } else if (address.chain && address.address) {
      await this.updateAddress(address);
    }
  }

  async updateAddress(address) {
    axios({
        method: 'post',
        url: routes.publishers.cryptoAddressForChannels.changeAddress.replace('{channel_id}', this.channel.id),
        data: {...address}
      }).then((response) => {
        this.handleConnectionResponse(response)
      });
  }

  deleteAddress(address, e) {
    axios({
        method: 'delete',
        url: routes.publishers.cryptoAddresses.delete.replace('{id}', address.id),
      }).then((response) => {
        this.handleConnectionResponse(response)
      });
  }

  render() {
    return (
      <div className="crypto-wallet-for-channel">
        <ErrorBoundary>
          <small><FormattedMessage id="walletServices.addCryptoWidget.widgetTitle" /></small>
          <div className="crypto-wallet-group">
            <div className='chain-label'><FormattedMessage id="walletServices.addCryptoWidget.ethereum" /></div>
            <Select
              options={this.state.ethOptions}
              onChange={this.changeAddress.bind(this)}
              components={{
                Option: CryptoWalletOption
              }}
              placeholder={<FormattedMessage id='walletServices.addCryptoWidget.notConnected' />}
              value={this.state.currentEthAddress}
              deleteAddress={this.deleteAddress.bind(this)}
              formatCryptoAddress={this.formatCryptoAddress.bind(this)}
              classNames={{
                control: () => 'crypto-wallet-dropdown crypto-wallet-dropdown-eth',
                dropdownIndicator: () => 'dropdown-indicator',
                indicatorSeparator: () => 'indicator-separator',
                menu: () => 'menu',
              }}
            />
          </div>
          <div className="crypto-wallet-group">
            <div className='chain-label'><FormattedMessage id="walletServices.addCryptoWidget.solana" /></div>
            <Select
              options={this.state.solOptions}
              onChange={this.changeAddress.bind(this)}
              components={{
                Option: CryptoWalletOption
              }}
              placeholder={<FormattedMessage id='walletServices.addCryptoWidget.notConnected' />}
              value={this.state.currentSolAddress}
              deleteAddress={this.deleteAddress.bind(this)}
              formatCryptoAddress={this.formatCryptoAddress.bind(this)}
              classNames={{
                control: () => 'crypto-wallet-dropdown crypto-wallet-dropdown-sol',
                dropdownIndicator: () => 'dropdown-indicator',
                indicatorSeparator: () => 'indicator-separator',
                menu: () => 'menu',
              }}
            />
          </div>
          <div className='alert-warning'>{this.state.errorText}</div>
        </ErrorBoundary>
      </div>
    );
  }
}

export default injectIntl(CryptoWalletServices);
