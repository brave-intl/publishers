module MockOauth2Responses
  include Oauth2::Structs

  def mock_unknown_failure(token_url)
    stub_request(:post, token_url)
      .to_return(status: 500, body: "any possible value")
  end

  def mock_token_failure(token_url)
    stub_request(:post, token_url)
      .to_return(status: 400, body: {error: "invalid_grant", error_description: "Ann error occurred"}.to_json)
  end

  def mock_refresh_token_success(token_url)
    stub_request(:post, token_url)
      .to_return(status: 200, body: {access_token: "access_token", expires_in: 10.minutes.to_i, refresh_token: "refresh_token", token_type: "example", scope: "create"}.to_json)
  end
end
