export class Wallet {
  constructor(data) {
    this._raw = data;

    this._rates = data.rates;

    this._status = data.status;

    this._channelBalances = data.channel_balances ? data.channel_balances : [];

    this._lastSettlementBalance = data.last_settlement_balance;

    this._lastSettlementDate = data.last_settlement_date;

    this._provider = data.provider;

    this._scope = data.scope;

    this._availableCurrencies = data.available_currencies;
    
    this._possibleCurrencies = data.possible_currencies;

    this._authorized = data.authorized;

    this._defaultCurrency = data.default_currency;

    this._ownerBalance = parseFloat(data.owner_balance).toFixed(2);
  }

  get lastSettlementBalance() {
    return this._lastSettlementBalance;
  }

  get lastSettlementDate() {
    return this._lastSettlementDate;
  }

  get channelBalances() {
    return this._channelBalances;
  }

  get ownerBalance() {
    return this._ownerBalance;
  }

  get defaultCurrency(){
    return this._defaultCurrency;
  }

  get possibleCurrencies(){
    return this._possibleCurrencies;
  }

  get rates (){
    return this._rates;
  }

  convertBatToDefaultCurrency(bat) {
    if (this.rates === undefined) {
      return undefined;
    }

    let default_currency = this.defaultCurrency;

    if (default_currency === "BAT") {
      return bat;
    }

    let rate = Number(this.rates[default_currency]);
    return bat * rate;
  }
}