
import { Wallet } from 'wallet';

const { module, test } = QUnit;

module('Wallet tests', function() {

  let walletDataWithSettlement = {"last_settlement_balance":120.034, "last_settlement_date":"2018-06-04T15:55:12.000-04:00","authorized":true,"provider":"uphold","scope":"cards:read cards:write user:read","default_currency":"USD","available_currencies":["USD","AED","ARS","AUD","BRL","CAD","CHF","CNY","EUR","GBP","HKD","ILS","JPY","KES","MXN","NOK","PHP","PLN","SEK","XAG","XAU","XPD","XPT"],"possible_currencies":["AED","ARS","AUD","BRL","CAD","CHF","CNY","DKK","EUR","GBP","HKD","ILS","INR","JPY","KES","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT"],"rates":{"BTC":"0.00003460","ETH":0.0006977401700426116,"LTC":0.003734731380391309,"USD":0.223313260989638,"EUR":0.19546185439229802},"action":null,"channel_balances":{},"owner_balance":0}
  let walletDataWithSettlementNoRateAvailable = {"last_settlement_balance":120.034, "last_settlement_date":"2018-06-04T15:55:12.000-04:00","authorized":true,"provider":"uphold","scope":"cards:read cards:write user:read","default_currency":"XPT","available_currencies":["USD","AED","ARS","AUD","BRL","CAD","CHF","CNY","EUR","GBP","HKD","ILS","JPY","KES","MXN","NOK","PHP","PLN","SEK","XAG","XAU","XPD","XPT"],"possible_currencies":["AED","ARS","AUD","BRL","CAD","CHF","CNY","DKK","EUR","GBP","HKD","ILS","INR","JPY","KES","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT"],"rates":{"BTC":"0.00003460","ETH":0.0006977401700426116,"LTC":0.003734731380391309,"USD":0.223313260989638,"EUR":0.19546185439229802},"action":null,"channel_balances":{},"owner_balance":0}
  let walletDataWithoutSettlement = {"authorized":true,"provider":"uphold","scope":"cards:read cards:write user:read","default_currency":"XPT","available_currencies":["USD","AED","ARS","AUD","BRL","CAD","CHF","CNY","EUR","GBP","HKD","ILS","JPY","KES","MXN","NOK","PHP","PLN","SEK","XAG","XAU","XPD","XPT"],"possible_currencies":["AED","ARS","AUD","BRL","CAD","CHF","CNY","DKK","EUR","GBP","HKD","ILS","INR","JPY","KES","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT"],"rates":{"BTC":"0.00003460","ETH":0.0006977401700426116,"LTC":0.003734731380391309,"USD":0.223313260989638,"EUR":0.19546185439229802},"action":null,"channel_balances":{},"owner_balance":0}
  let walletDataNotUpholdVerified = {"authorized":null,"provider":null,"scope":null,"default_currency":null,"available_currencies":[],"possible_currencies":[],"rates":{"BTC":"0.00003460","ETH":0.000693429574410605,"LTC":0.0037251486291237723,"USD":0.223313260989638,"EUR":0.19546185439229802},"action":null,"channel_balances":{},"owner_balance":0};

  test ('can get owner balance from wallet', function(assert){
    let wallet = new Wallet(walletDataWithSettlement);

    assert.equal('0.00', wallet.ownerBalance, "ownerBalance is defined");
  });

  test ('can get default currency from wallet', function(assert) {
    let wallet = new Wallet(walletDataWithSettlement);

    assert.equal('USD', wallet.defaultCurrency, "default currency is defined");
  });

  test('converts BAT to default currency', function(assert) {
    let walletNoRate = new Wallet(walletDataWithSettlementNoRateAvailable);
    let convertedBalance = walletNoRate.convertBatToDefaultCurrency(walletNoRate.ownerBalance);
    assert.ok(isNaN(convertedBalance), 'returns NaN if rate is unavailable');

    let walletWithRate = new Wallet(walletDataWithSettlement);
    let convertedBalanceWithRate = walletWithRate.convertBatToDefaultCurrency(walletWithRate.ownerBalance);
    assert.equal(convertedBalanceWithRate, '0.00', 'returns converted balance is rate is available');
  });

  test('initializes from json with settlement data', function(assert) {
    let wallet = new Wallet(walletDataWithSettlement);

    assert.equal(wallet.defaultCurrency, 'USD', "defaultCurrency set");
    assert.equal(wallet.lastSettlementBalance, '120.034', "lastSettlementAmount is object with correct bat");
    assert.equal(wallet.convertBatToDefaultCurrency(wallet.lastSettlementBalance), '26.80518396963021', 'converts last settlement balance to default currency')
  });

  test('initializes from json without settlement data', function(assert) {
    let wallet = new Wallet(walletDataWithoutSettlement);

    assert.equal(wallet.lastSettlementBalance, undefined, "lastSettlementAmount is undefined when last settlement isn't available");
  });

  test('initializes from json without uphold wallet data', function(assert) {
    let wallet = new Wallet(walletDataNotUpholdVerified);

    assert.equal(wallet.providerWallet, undefined, "defaultCurrency is undefined when user isn't verified with Uphold");
  });
});
