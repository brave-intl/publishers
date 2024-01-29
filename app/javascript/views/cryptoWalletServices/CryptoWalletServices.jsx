import * as React from "react";
import { FormattedMessage, injectIntl } from "react-intl";
import ErrorBoundary from "../../components/errorBoundary/ErrorBoundary";
import CryptoWalletOption from './CryptoWalletOption';
import CryptoPrivacyModal from './CryptoPrivacyModal';
import Select from 'react-select';
import axios from "axios";
import routes from "../routes";
import bs58 from 'bs58';
import Modal, { ModalSize } from "../../components/modal/Modal";
import TryBraveModal from "../publicChannelPage/TryBraveModal";

class CryptoWalletServices extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.intl = props.intl;
    this.store = props.store;

    this.store.subscribe(this.updateOptionsFromStore.bind(this))

    this.state = {
      addressesInUse: this.store.getState().addressesInUse,
      solOptions: [],
      ethOptions: [],
      currentSolAddress: null,
      currentEthAddress: null,
      isLoading: true,
      errorText: null,
      isModalOpen: false,
      isTryBraveModalOpen: false,
      pendingAddress: null,
    };
  }

  componentDidMount() {
    this.loadData();
  }


  closeTryBraveModal = () => {
    this.setState({ isTryBraveModalOpen: false });
  };

  launchTryBraveModal = async () => {
    const newState = {...this.state};
    newState.isTryBraveModalOpen = true;
    this.setState({...newState });
  };

  updateOptionsFromStore(action) {
    if (action.type === 'UPDATE_RESPONSE_DATA') {
      const newEthOptions = this.formatOptionData(action.payload, this.state.currentEthAddress, 'ETH');
      const newSolOptions = this.formatOptionData(action.payload, this.state.currentSolAddress, 'SOL');
      
      this.setState({ ethOptions: newEthOptions });
      this.setState({ solOptions: newSolOptions });

      if (this.state.currentSolAddress && newSolOptions.filter(sol => sol.value.address === this.state.currentSolAddress.value.address).length < 1) {
        this.setState({currentSolAddress: null});
      }
      if (this.state.currentEthAddress && newEthOptions.filter(eth => eth.value.address === this.state.currentEthAddress.value.address).length < 1) {
        this.setState({currentEthAddress: null});
      }
    }
  }

  // Helper functions
  formatOptionData(response, currentAddress, chain) {
    const options = response.data.filter( address => address.chain === chain)
                      .map( address => { return { value: address, label: address.address}})
    
    options.push({label: this.intl.formatMessage({id: 'walletServices.addCryptoWidget.addWallet'}), value: {newAddress: chain}});
    options.push({label: this.intl.formatMessage({id: 'walletServices.addCryptoWidget.clearWallet'}), value: {clearAddress: chain, deletedAddress: currentAddress }});
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

    // clear out old addresses before adding them back to the store
    if (this.state.currentEthAddress) {
      this.store.dispatch({
        type: "REMOVE_ADDRESS",
        payload: { removedAddress: this.state.currentEthAddress.value.id }
      });
    }
    if (this.state.currentSolAddress) {
      this.store.dispatch({
        type: "REMOVE_ADDRESS",
        payload: { removedAddress: this.state.currentSolAddress.value.id }
      });
    }
    
    axios.get(routes.publishers.cryptoAddresses.index).then((response) => {
      const newState = {
        addressesInUse: this.store.getState().addressesInUse,
        isLoading: false,
        errorText: null,
      };
      
      axios.get(routes.publishers.cryptoAddressForChannels.index.replace('{channel_id}', this.channel.id)).then((channelResponse) => {
        newState.currentSolAddress = this.findCurrentAddress('SOL', channelResponse, response)
        newState.currentEthAddress = this.findCurrentAddress('ETH', channelResponse, response)

        if (newState.currentSolAddress) {
          this.store.dispatch({
            type: "ADD_ADDRESS",
            payload: { newAddress: newState.currentSolAddress.value }
          });
        }

        if (newState.currentEthAddress) {
          this.store.dispatch({
            type: "ADD_ADDRESS",
            payload: { newAddress: newState.currentEthAddress.value }
          });
        }

        this.store.dispatch({
          type: "UPDATE_RESPONSE_DATA",
          payload: response,
        })

        newState.ethOptions = this.formatOptionData(response, newState.currentEthAddress, 'ETH');
        newState.solOptions = this.formatOptionData(response, newState.currentSolAddress, 'SOL');

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
      await this.launchTryBraveModal();
      this.setErrorText(this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.solanaConnectError' }));
      return false;
    }

    const results = await window.solana.connect();
    if (results.publicKey) {
      const pub_key = results.publicKey

      const possibleMatch = this.state.solOptions.filter(sol => sol.value.address === pub_key);
      if (possibleMatch.length > 0) {
        if (this.state.addressesInUse.filter(usedAddress => usedAddress.address === pub_key).length > 0) {
          this.launchPrivacyModal(possibleMatch[0].value);
        } else {
          await this.updateAddress(possibleMatch[0].value);
        }
        return;
      }

      const nonce = await this.getNonce();
      if (!nonce) {
        this.setErrorText(this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.genericError' }))
        return;
      }
      const encodedMessage = new TextEncoder().encode(nonce)
      let signedMessage = null

      try {
        signedMessage = await window.solana.signMessage(encodedMessage, "utf8")
      } catch (err) {
        this.setErrorText(this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.solanaConnectionFailure' }))
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
        this.setErrorText(this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.ethereumConnectError' }));
        return;
      }

      const possibleMatch = this.state.ethOptions.filter(eth => eth.value.address && eth.value.address.toLowerCase() === address.toLowerCase());
      if (possibleMatch.length > 0) {
        if (this.state.addressesInUse.filter(usedAddress => usedAddress.address === address).length > 0) {
          this.launchPrivacyModal(possibleMatch[0].value);
        } else {
          await this.updateAddress(possibleMatch[0].value);
        }
        return;
      }

      const nonce = await this.getNonce();
      if (!nonce) {
        this.setErrorText(this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.genericError' }))
        return;
      }

      const signature = await window.ethereum.request({
        method: 'personal_sign',
        params: [address, nonce]
      })

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
      await this.launchTryBraveModal();
      this.setErrorText(this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.ethereumConnectError' }));
      return;
    }
  }

  // UI helpers for api responses
  handleConnectionResponse = (response) => {
    if (response.status < 300) {
      this.loadData();
    } else {
      setErrorText(this.intl.formatMessage({ id: 'walletServices.addCryptoWidget.addressConnectFailure' }))
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
    } else if (address.clearAddress) {
      await this.deleteAddress(address.deletedAddress.value);
    } else if (address.chain && address.address) {
      if (this.state.addressesInUse.filter(usedAddress => usedAddress.id === address.id).length > 0) {
        this.launchPrivacyModal(address);
      } else {
        await this.updateAddress(address);
      }
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

  deleteAddress(address) {
    axios({
        method: 'delete',
        url: routes.publishers.cryptoAddresses.delete.replace('{id}', address.id),
      }).then((response) => {
        this.handleConnectionResponse(response)
      });
  }

  launchPrivacyModal(pendingAddress) {
    this.setState({ isModalOpen: true, pendingAddress });
  }

  closeModal = () => {
    this.setState({ isModalOpen: false, pendingAddress: null });
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
          {(this.state.currentSolAddress || this.state.currentEthAddress) && (
            <a href={`/c/${this.channel.public_identifier}`}><FormattedMessage id="walletServices.addCryptoWidget.channelPageLink" /></a>
          )}
          <Modal
            show={this.state.isModalOpen}
            size={ModalSize.ExtraSmall}
            handleClose={() => this.closeModal()}
          >
            <CryptoPrivacyModal
              close={this.closeModal}
              updateAddress={this.updateAddress.bind(this)}
              address={this.state.pendingAddress}
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
        </ErrorBoundary>
      </div>
    );
  }
}

export default injectIntl(CryptoWalletServices);
