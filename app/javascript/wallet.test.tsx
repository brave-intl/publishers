import { Wallet } from './wallet';

describe('Wallet', () => {
  let walletData = {"rates":{"BTC":5.418424016883016e-05,"ETH":0.000795331082073117,"USD":0.2363863335301452,"EUR":0.20187818378874756,"GBP":0.1799810085548496},"authorized":true,"provider":"uphold","scope":"cards:read user:read","default_currency":"GBP","available_currencies":["USD","EUR","BTC","ETH","BAT"],"possible_currencies":["AED","ARS","AUD","BRL","CAD","CHF","CNY","DKK","EUR","GBP","HKD","ILS","INR","JPY","KES","MXN","NOK","NZD","PHP","PLN","SEK","SGD","USD","XAG","XAU","XPD","XPT"],"address":"","action":null,"channel_balances":{"youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw":{"rates":{"BTC":5.418424016883016e-05,"ETH":0.000795331082073117,"USD":0.2363863335301452,"EUR":0.20187818378874756,"GBP":0.1799810085548496},"default_currency":"GBP","amount_probi":"0","fees_probi":"0","amount_bat":"0.00","fees_bat":"0.00","amount_default_currency":"0.00","fees_default_currency":"0.00"}},"referral_balance":{"rates":{"BTC":5.418424016883016e-05,"ETH":0.000795331082073117,"USD":0.2363863335301452,"EUR":0.20187818378874756,"GBP":0.1799810085548496},"default_currency":"GBP","amount_bat":"0.00","fees_bat":"0.00","amount_probi":"0","fees_probi":"0","amount_default_currency":"0.00","fees_default_currency":"0.00"},"overall_balance":{"rates":{"BTC":5.418424016883016e-05,"ETH":0.000795331082073117,"USD":0.2363863335301452,"EUR":0.20187818378874756,"GBP":0.1799810085548496},"default_currency":"GBP","amount_probi":"0","fees_probi":"0","amount_bat":"0.00","fees_bat":"0.00","amount_default_currency":"0.00","fees_default_currency":"0.00"},"last_settlement_balance":{"rates":{"BTC":5.418424016883016e-05,"ETH":0.000795331082073117,"USD":0.2363863335301452,"EUR":0.20187818378874756,"GBP":0.1799810085548496},"default_currency":"GBP","amount_bat":"75.62","timestamp":1544158800,"settlement_currency":"ETH","amount_settlement_currency":"0.06"}}

  it('initializes wallet info from json', () => {
    let wallet = new Wallet(walletData);
    expect(wallet.defaultCurrency).toEqual("GBP")
    expect(wallet.authorized).toEqual(true)
    expect(wallet.availableCurrencies.includes("USD")).toEqual(true)
    expect(wallet.possibleCurrencies.includes("HKD")).toEqual(true)
  });

  it('initializes balance info from json', () => {
    let wallet = new Wallet(walletData);

    let overallBalance = wallet.overallBalance
    expect(overallBalance.amount_bat).toEqual("0.00")
    expect(overallBalance.amount_default_currency).toEqual("0.00")

    let channelBalance = wallet.channelBalances["youtube#channel:UCtsfHRe2WQnkNH5WYJWL-Yw"]
    expect(channelBalance.amount_bat).toEqual("0.00")
    expect(channelBalance.amount_default_currency).toEqual("0.00")

    let referralBalance = wallet.referralBalance
    expect(referralBalance.amount_bat).toEqual("0.00")
    expect(referralBalance.amount_default_currency).toEqual("0.00")

    let lastSettlementBalance = wallet.lastSettlementBalance
    expect(lastSettlementBalance.amount_bat).toEqual("75.62");
    expect(lastSettlementBalance.amount_settlement_currency).toEqual("0.06");
  });
})
