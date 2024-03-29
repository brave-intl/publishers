export class Wallet {
  constructor(data) {
    this._raw = data;

    // Wallet info
    this.authorized = data.authorized;
    this.defaultCurrency = data.default_currency;

    // Balance info
    this.channelBalances = data.channel_balances ? data.channel_balances : [];
    this.referralBalance = data.referral_balance ? data.referral_balance : {};
    this.overallBalance = data.overall_balance ? data.overall_balance : {};
    this.lastSettlementBalance = data.last_settlement_balance ? data.last_settlement_balance : {};
  }
}
