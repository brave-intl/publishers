# typed: false

module MockGeminiResponses
  # This will stub requests out for all the different Gemini requests.
  # We create regular expensions to ensure that the request is mocked regardless of any query params
  def mock_gemini_auth_request!
    path = Gemini::Auth::PATH.expand(segments: "token")
    regex = Regexp.new(path)

    response = {
      access_token: "km2bylijaDkceTOi2LiranELqdQqvsjFuHcSuQ5aU9jm",
      expires_in: 189561,
      scope: "Auditor",
      refresh_token: "6ooHciJa8nqwV5pFEyBAbt25Q7kZ16VAnS31p7xdSR9",
      token_type: "Bearer"
    }
    stub_request(:post, regex).to_return(body: response.to_json)
  end

  def mock_gemini_account_request!
    path = Gemini::Account::PATH.expand(segments: nil).to_s
    regex = Regexp.new(path)

    response = {
      account: {
        accountName: "Primary",
        shortName: "primary",
        type: "exchange",
        created: "1594238561617"
      },
      users: [
        {
          name: "Alice Publisher",
          lastSignIn: "2020-07-20T21:16:39.563Z",
          status: "Active",
          countryCode: "US",
          isVerified: true
        }
      ],
      memo_reference_code: "GEMMQDMPJ"
    }
    stub_request(:post, regex).to_return(body: response.to_json)
  end

  def mock_gemini_blocked_country_account_request!
    path = Gemini::Account::PATH.expand(segments: nil).to_s
    regex = Regexp.new(path)

    response = {
      account: {
        accountName: "Primary",
        shortName: "primary",
        type: "exchange",
        created: "1594238561617"
      },
      users: [
        {
          name: "Alice Publisher",
          lastSignIn: "2020-07-20T21:16:39.563Z",
          status: "Active",
          countryCode: "AQ",
          isVerified: true
        }
      ],
      memo_reference_code: "GEMMQDMPJ"
    }
    stub_request(:post, regex).to_return(body: response.to_json)
  end

  def mock_gemini_unverified_account_request!
    path = Gemini::Account::PATH.expand(segments: nil).to_s
    regex = Regexp.new(path)

    response = {
      account: {
        accountName: "Primary",
        shortName: "primary",
        type: "exchange",
        created: "1594238561617"
      },
      users: [
        {
          name: "Alice Publisher",
          lastSignIn: "2020-07-20T21:16:39.563Z",
          status: "Active",
          countryCode: "US",
          isVerified: false
        }
      ],
      memo_reference_code: "GEMMQDMPJ"
    }
    stub_request(:post, regex).to_return(body: response.to_json)
  end

  def mock_gemini_recipient_id!(recipient_id: "abcd")
    path = Gemini::RecipientId::PATH
    regex = Regexp.new(path)

    response = [{recipient_id: recipient_id.to_s, label: "Brave Creators"}, {recipient_id: "#{recipient_id}2", label: "Brave Creators"}]
    stub_request(:get, regex).to_return(body: response.to_json)
  end

  def mock_gemini_channels_recipient_id!(recipient_id: "1234", label: "Brave Creators")
    path = Gemini::RecipientId::PATH
    regex = Regexp.new(path)

    response = {recipient_id: recipient_id.to_s, label: label}
    stub_request(:post, regex).to_return(body: response.to_json)
  end
end
