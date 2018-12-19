import { Wallet } from './wallet';

describe('Wallet', () => {
  let walletDataWithSettlement = {"lastSettlement":{"balance":{"probi":53213081343122476086},"date":"2018-06-04T15:55:12.000-04:00"},"providerWallet":{"provider":"uphold","authorized":true,"defaultCurrency":"USD","rates":{"BTC":"0.00003514","ETH":0.0004749371464487743,"LTC":0.0022794117647058827,"USD":0.28188557439999995,"EUR":0.24163829927299837},"availableCurrencies":["USD","BAT","BTC","EUR","XAU"],"possibleCurrencies":["AED","ARS","AUD","BAT","BCH","BRL","BTC","BTG","CAD","CHF","CNY","DASH","DKK","ETH","EUR","GBP","HKD","ILS","INR","JPY","KES","LTC","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT","XRP"],"scope":"cards:read user:read transactions:transfer:others"},"channelBalances":{"youtube#channel:UC1CF3Uud5SZJAOtusRcaMZg":{"probi":17737693781040825362},"youtube#channel:UCpspxI6hEuK9AVxNMtZsObA":{"probi":17737693781040825362}}};
  let walletDataWithoutSettlement = {"providerWallet":{"provider":"uphold","authorized":true,"defaultCurrency":"USD","rates":{"BTC":"0.00003514","ETH":0.0004749371464487743,"LTC":0.0022794117647058827,"USD":0.28188557439999995,"EUR":0.24163829927299837},"availableCurrencies":["USD","BAT","BTC","EUR","XAU"],"possibleCurrencies":["AED","ARS","AUD","BAT","BCH","BRL","BTC","BTG","CAD","CHF","CNY","DASH","DKK","ETH","EUR","GBP","HKD","ILS","INR","JPY","KES","LTC","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT","XRP"],"scope":"cards:read user:read transactions:transfer:others"},"channelBalances":{"youtube#channel:UC1CF3Uud5SZJAOtusRcaMZg":{"probi":17737693781040825362},"youtube#channel:UCpspxI6hEuK9AVxNMtZsObA":{"probi":17737693781040825362}}};
  let walletDataNotUpholdVerified = {};

  it('Converts probi to BAT', () => {
    expect(Wallet._probi_to_bat(5E20)).toEqual(500)
    expect(Wallet._probi_to_bat("5.01E20")).toEqual(501)
  })

  it('initializes from json with settlement data', () => {
    const wallet = new Wallet(walletDataWithSettlement);

    expect(wallet.providerWallet.defaultCurrency).toEqual("USD");
    expect(wallet.lastSettlement.amount.bat).toEqual(53.213081343122475);
    expect(wallet.lastSettlement.amount.converted).toEqual(53.213081343122475 * 0.28188557439999995);
    expect(wallet.lastSettlement.amount.currency).toEqual("USD");
  });

  it('initializes from json without settlement data', () => {
    const wallet = new Wallet(walletDataWithoutSettlement);

    expect(wallet.lastSettlement.amount).toBeUndefined();
  });

  it('initializes from json without uphold wallet data', () => {
    let wallet = new Wallet(walletDataNotUpholdVerified);

    expect(wallet.providerWallet).toBeUndefined();
  });

  it('adds up total channel amounts and converts to default currency', () => {
    let wallet = new Wallet(walletDataWithSettlement);

    expect(wallet.totalAmount.bat).toEqual(17.737693781040825362 + 17.737693781040825362);
    expect(wallet.totalAmount.converted).toEqual(10);
    expect(wallet.totalAmount.currency).toEqual("USD");
  });

  it('total channel amount is 0 if there are no channels', () => {
    let wallet = new Wallet(walletDataNotUpholdVerified);

    expect(wallet.totalAmount.bat).toEqual(0);
    expect(wallet.totalAmount.converted).toBeUndefined();
    expect(wallet.totalAmount.currency).toBeUndefined();
  });
})
