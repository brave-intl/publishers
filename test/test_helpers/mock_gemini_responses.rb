module MockGeminiResponses
  # This will stub requests out for all the different Gemini requests.
  # We create regular expensions to ensure that the request is mocked regardless of any query params
  def mock_gemini_auth_request!
    path = Gemini::Auth::PATH.expand(segments: 'token')
    regex = Regexp.new(path)

    response = {
      "access_token": "km2bylijaDkceTOi2LiranELqdQqvsjFuHcSuQ5aU9jm",
      "expires_in": 189561,
      "scope": "Auditor",
      "refresh_token": "6ooHciJa8nqwV5pFEyBAbt25Q7kZ16VAnS31p7xdSR9",
      "token_type": "Bearer",
    }
    stub_request(:post, regex).to_return(body: response.to_json)
  end

  def mock_gemini_account_request!
    path = Gemini::Account::PATH.expand(segments: nil).to_s
    regex = Regexp.new(path)

    response = {
      "account": {
        "accountName": "Primary",
        "shortName": "primary",
        "type": "exchange",
        "created": "1594238561617",
      },
      "users": [
        {
          "name": "Alice Publisher",
          "lastSignIn": "2020-07-20T21:16:39.563Z",
          "status": "Active",
          "countryCode": "US",
          "isVerified": true,
        },
      ],
      "memo_reference_code": "GEMMQDMPJ",
    }
    stub_request(:post, regex).to_return(body: response.to_json)
  end

  def mock_gemini_recipient_id!
    path = Gemini::RecipientId::PATH
    regex = Regexp.new(path)

    response = [{ "recipient_id": "5f0cdc2f-622b-4c30-ad9f-3a5e6dc85079", "label": "Brave Rewards | Creators" }, { "recipient_id": "5f0cdcb3-5f3f-45bb-a982-150a3e41acb1", "label": "Brave Rewards | Creators" }]
    stub_request(:get, regex).to_return(body: response.to_json)
  end
end
