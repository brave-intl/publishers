module MockOauth2Responses
  include Oauth2::Responses

  def mock_unknown_failure(token_url, status: 500)
    stub_request(:post, token_url)
      .to_return(status: status, body: "any possible value")
  end

  def mock_token_failure(token_url, to_spec: true)
    payload = {error: "invalid_grant", error_description: "Ann error occurred"}

    if !to_spec
      payload[:another] = "value"
    end

    stub_request(:post, token_url)
      .to_return(status: 400, body: payload.to_json)
  end

  def mock_refresh_token_success(token_url, to_spec: true)
    payload = {access_token: "access_token", expires_in: 10.minutes.to_i, refresh_token: "refresh_token", token_type: "example", scope: "create"}

    if !to_spec
      payload[:another] = "value"
    end

    stub_request(:post, token_url)
      .to_return(status: 200, body: payload.to_json)
  end
end
