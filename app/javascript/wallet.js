export class Wallet {
  constructor(data) {
    this._raw = data;

    this._providerWallet = data.providerWallet;

    this._status = data.status;

    this._channelBalances = data.channelBalances ? data.channelBalances : {};

    if ((data.lastSettlement) && (data.lastSettlement.balance) && (data.lastSettlement.balance.probi)) {
      this._lastSettlement = {
        amount: this._formatAmount(Wallet._probi_to_bat(data.lastSettlement.balance.probi)),
        date: new Date(data.lastSettlement.date)
      };
    }
    else {
      this._lastSettlement = {
        amount: undefined,
        date: undefined
      };
    }

    // Total the channel balances
    let total = 0.0;
    for (let key in this._channelBalances) {
      total = total + this._getChannelBat(key);
    }
    this._totalAmount = this._formatAmount(total);
  }

  get status() {
    return this._status;
  }

  get providerWallet() {
    return this._providerWallet;
  }

  get lastSettlement() {
    return this._lastSettlement;
  }

  get channelBalances() {
    return this._channelBalances;
  }

  get totalAmount() {
    return this._totalAmount;
  }

  getChannelAmount(channel) {
    return this._formatAmount(this._getChannelBat(channel));
  }

  _convertBatToDefaultCurrency(bat) {
    if ((this.providerWallet === undefined) || (this.providerWallet.rates === undefined)) {
      return undefined;
    }

    let default_currency = this._providerWallet.defaultCurrency;

    if (default_currency === "BAT") {
      return bat;
    }

    let rate = Number(this.providerWallet.rates[default_currency]);
    return bat * rate;
  }

  _formatAmount(bat) {
    return {
      bat: Number(bat),
      converted: this._convertBatToDefaultCurrency(bat),
      currency: this.providerWallet ? this.providerWallet.defaultCurrency : undefined
    };
  }

  static _probi_to_bat(probi) {
    return Number(probi) / 1E18;
  }

  _getChannelBat(channel) {
    let balance = 0;
    if (this._channelBalances[channel].probi) {
      balance = Wallet._probi_to_bat(this._channelBalances[channel].probi);
    }

    return balance;
  }
}