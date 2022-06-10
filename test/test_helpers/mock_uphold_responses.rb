# typed: false
module MockUpholdResponses
  def stub_uphold_cards!
    stub_request(:get, /v0\/me\/cards\?q=currency:USD/).to_return(body: [].to_json)
    stub_request(:get, /v0\/me\/cards/).to_return(body: "{}")
    stub_request(:post, /v0\/me\/cards/).to_return(body: {id: "123e4567-e89b-12d3-a456-426655440000"}.to_json)
  end

  # https://uphold.com/en/developer/api/documentation/#list-cards
  def stub_list_cards(id: "024e51fc-5513-4d82-882c-9b22024280cc", currency: "BTC", label: UpholdConnection::UPHOLD_CARD_LABEL, empty: false)
    body = [{
      "address": {
        "bitcoin": "mkZuBgFa4gAjJ2UckDA3Pms68rVBavAneF"
      },
      "available": "5.00",
      "balance": "5.00",
      "currency": currency,
      "id": id, 
      "label": label,
      "lastTransactionAt": "2018-08-01T09:53:44.617Z",
      "normalized": [{
        "available": "4500.00",
        "balance": "4500.00",
        "currency": "USD"
      }],
      "settings": {
        "position": 1,
        "protected": false,
        "starred": true
      }
    },
    {
      "address": {
        "bitcoin": "ms22VBPSahNTxHZNkYo2d4Rmw1Tgfx6ojr"
      },
      "available": "146.38",
      "balance": "146.38",
      "currency": "EUR",
      "id": "bc9b3911-4bc1-4c6d-ac05-0ae87dcfc9b3",
      "label": "EUR card",
      "lastTransactionAt": "2018-08-01T09:53:51.258Z",
      "normalized": [{
        "available": "170.96",
        "balance": "170.96",
        "currency": "USD"
      }],
      "settings": {
        "position": 2,
        "protected": false,
        "starred": true
      }
    }] 

    stub_request(:get, /v0\/me\/cards/).to_return(body: empty ? [].to_json : body.to_json)
  end

  def stub_get_card(id: "024e51fc-5513-4d82-882c-9b22024280cc", currency: "BTC", label: UpholdConnection::UPHOLD_CARD_LABEL)
    body = {
      "address": {
        "bitcoin": "ms22VBPSahNTxHZNkYo2d4Rmw1Tgfx6ojr"
      },
      "available": "146.38",
      "balance": "146.38",
      "currency": currency,
      "id": id,
      "label": label,
      "lastTransactionAt": "2018-08-01T09:53:51.258Z",
      "normalized": [{
        "available": "170.96",
        "balance": "170.96",
        "currency": "USD"
      }],
      "settings": {
        "position": 2,
        "protected": false,
        "starred": true
      }
    }    

    stub_request(:get, /v0\/me\/cards\/#{id}/).to_return(body: body.to_json)
  end

  def stub_create_card(id: "024e51fc-5513-4d82-882c-9b22024280cc", currency: "BTC", label: UpholdConnection::UPHOLD_CARD_LABEL, settings: {})
    body = {
      "address": {
        "bitcoin": "ms22VBPSahNTxHZNkYo2d4Rmw1Tgfx6ojr"
      },
      "available": "146.38",
      "balance": "146.38",
      "currency": currency,
      "id": id,
      "label": label,
      "lastTransactionAt": "2018-08-01T09:53:51.258Z",
      "normalized": [{
        "available": "170.96",
        "balance": "170.96",
        "currency": "USD"
      }],
      "settings": settings
    }    

    path = "/v0/me/cards"

    stub_request(:post, /v0\/me\/cards/).to_return(body: body.to_json)
  end

  def stub_get_user
    body = {
      "address": {
        "city": "Ryleighfort",
        "line1": "32167 Mohr Land",
        "line2": "Suite 257",
        "zipCode": "47890"
      },
      "balances": {
        "currencies": {
          "BTC": {
            "amount": "4500.00",
            "balance": "5.00",
            "currency": "USD",
            "rate": "900.00000"
          },
          "EUR": {
            "amount": "180.89",
            "balance": "154.88",
            "currency": "USD",
            "rate": "1.16795"
          },
          "USD": {
            "amount": "17710.05",
            "balance": "17710.05",
            "currency": "USD",
            "rate": "1.00000"
          }
        },
        "total": "22390.94"
      },
      "birthdate": "2000-09-27",
      "country": "US",
      "currencies": [
        "BTC",
        "CNY",
        "ETH",
        "EUR",
        "GBP",
        "JPY",
        "LTC",
        "USD",
        "XAU",
        "XRP"
      ],
      "email": "malika.koss@example.com",
      "firstName": "Malika",
      "id": "21e65c4d-55e4-41be-97a1-ff38d8f3d945",
      "lastName": "Koss",
      "memberAt": "2018-08-01T09:53:44.293Z",
      "name": "Malika Koss",
      "phones": [{
        "e164Masked": "+XXXXXXXXX66",
        "id": "abefe0b6-2f5d-45ba-97ac-3b07b08595a3",
        "internationalMasked": "+X XXX-XXX-XX66",
        "nationalMasked": "(XXX) XXX-XX66",
        "primary": true,
        "verified": true
      }],
      "settings": {
        "currency": "USD",
        "hasMarketingConsent": false,
        "hasNewsSubscription": false,
        "intl": {
          "dateTimeFormat": {
            "locale": "en-US"
          },
          "language": {
            "locale": "en-US"
          },
          "numberFormat": {
            "locale": "en-US"
          }
        },
        "otp": {
          "login": {
            "enabled": true
          },
          "transactions": {
            "send": {
              "enabled": true
            },
            "transfer": {
              "enabled": false
            },
            "withdraw": {
              "crypto": {
                "enabled": true
              }
            }
          },
          "vmc": {
            "enabled": true
          }
        }
      },
      "state": "US-UT",
      "status": "ok",
      "type": "individual",
      "verifications": {}
    }

    stub_request(:get, /v0\/me/).to_return(body: body.to_json)
  end
end
