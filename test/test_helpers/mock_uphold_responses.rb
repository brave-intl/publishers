# typed: false
module MockUpholdResponses
  def stub_uphold_cards!
    stub_request(:get, /v0\/me\/cards\?q=currency:USD/).to_return(body: [].to_json)
    stub_request(:get, /v0\/me\/cards/).to_return(body: "{}")
    stub_request(:post, /v0\/me\/cards/).to_return(body: {id: "123e4567-e89b-12d3-a456-426655440000"}.to_json)
  end

  # https://uphold.com/en/developer/api/documentation/#list-cards
  def stub_list_cards(id: "024e51fc-5513-4d82-882c-9b22024280cc", currency: "BTC", label: UpholdConnection::UPHOLD_CARD_LABEL)
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

    stub_request(:get, /v0\/me\/cards/).to_return(body: body.to_json)
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
end
