import { Wallet } from 'wallet';

const { module, test } = QUnit;

module('Wallet tests', function() {
  let walletDataWithSettlement = {"lastSettlement":{"balance":{"probi":53213081343122476086},"date":"2018-06-04T15:55:12.000-04:00"},"providerWallet":{"provider":"uphold","authorized":true,"defaultCurrency":"USD","rates":{"BTC":"0.00003514","ETH":0.0004749371464487743,"LTC":0.0022794117647058827,"USD":0.28188557439999995,"EUR":0.24163829927299837},"availableCurrencies":["USD","BAT","BTC","EUR","XAU"],"possibleCurrencies":["AED","ARS","AUD","BAT","BCH","BRL","BTC","BTG","CAD","CHF","CNY","DASH","DKK","ETH","EUR","GBP","HKD","ILS","INR","JPY","KES","LTC","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT","XRP"],"scope":"cards:read user:read transactions:transfer:others"},"channelBalances":{"youtube#channel:UC1CF3Uud5SZJAOtusRcaMZg":{"probi":17737693781040825362},"youtube#channel:UCpspxI6hEuK9AVxNMtZsObA":{"probi":17737693781040825362}}};
  let walletDataWithoutSettlement = {"providerWallet":{"provider":"uphold","authorized":true,"defaultCurrency":"USD","rates":{"BTC":"0.00003514","ETH":0.0004749371464487743,"LTC":0.0022794117647058827,"USD":0.28188557439999995,"EUR":0.24163829927299837},"availableCurrencies":["USD","BAT","BTC","EUR","XAU"],"possibleCurrencies":["AED","ARS","AUD","BAT","BCH","BRL","BTC","BTG","CAD","CHF","CNY","DASH","DKK","ETH","EUR","GBP","HKD","ILS","INR","JPY","KES","LTC","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT","XRP"],"scope":"cards:read user:read transactions:transfer:others"},"channelBalances":{"youtube#channel:UC1CF3Uud5SZJAOtusRcaMZg":{"probi":17737693781040825362},"youtube#channel:UCpspxI6hEuK9AVxNMtZsObA":{"probi":17737693781040825362}}};
  let walletDataNotUpholdVerified = {};

  test('converts probi to bat', function(assert) {
    assert.equal(Wallet._probi_to_bat(5E20), 500, "converted probi to bat");
    assert.equal(Wallet._probi_to_bat("5.01E20"), 501, "converted probi string to bat");
  });

  test('initializes from json with settlement data', function(assert) {
    let wallet = new Wallet(walletDataWithSettlement);

    assert.equal(wallet.providerWallet.defaultCurrency, "USD", "defaultCurrency set");
    assert.equal(wallet.lastSettlement.amount.bat, 53.213081343122475, "lastSettlementAmount is object with correct bat");
    assert.equal(wallet.lastSettlement.amount.converted, 53.213081343122475 * 0.28188557439999995, "lastSettlementAmount is object with correct converted amount");
    assert.equal(wallet.lastSettlement.amount.currency, "USD", "lastSettlementAmount is object with correct currency");
  });

  test('initializes from json without settlement data', function(assert) {
    let wallet = new Wallet(walletDataWithoutSettlement);

    assert.equal(wallet.lastSettlement.amount, undefined, "lastSettlementAmount is undefined when last settlement isn't available");
  });

  test('initializes from json without uphold wallet data', function(assert) {
    let wallet = new Wallet(walletDataNotUpholdVerified);

    assert.equal(wallet.providerWallet, undefined, "defaultCurrency is undefined when user isn't verified with Uphold");
  });

  test('adds up total channel amounts and converts to default currency', function(assert) {
    let wallet = new Wallet(walletDataWithSettlement);

    assert.equal(wallet.totalAmount.bat, 17.737693781040825362 + 17.737693781040825362, "totalAmount is object with correct bat");
    assert.equal(wallet.totalAmount.converted, 10, "totalAmount is object with correct converted amount");
    assert.equal(wallet.totalAmount.currency, "USD", "totalAmount is object with correct currency");
  });

  test('total channel amount is 0 if there are no channels', function(assert) {
    let wallet = new Wallet(walletDataNotUpholdVerified);

    assert.equal(wallet.totalAmount.bat, 0, "totalAmount is object with correct bat");
    assert.equal(wallet.totalAmount.converted, undefined, "totalAmount is object with undefined converted amount");
    assert.equal(wallet.totalAmount.currency, undefined, "totalAmount is object with undefined currency");
  });
});
