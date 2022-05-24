module MockBitflyerResponses
  def mock_create_deposit_id_success(deposit_id = "any value")
    stub_request(:get, /api\/link\/v1\/account\/create-deposit-id/)
      .to_return(status: 200, body: {deposit_id: deposit_id}.to_json)
  end

  def mock_create_deposit_id_bad_request(deposit_id = "any value")
    stub_request(:get, /api\/link\/v1\/account\/create-deposit-id/)
      .to_return(status: 400, body: {}.to_json)
  end

  def mock_create_deposit_id_unauthorized(deposit_id = "any value")
    stub_request(:get, /api\/link\/v1\/account\/create-deposit-id/)
      .to_return(status: 401, body: {}.to_json)
  end
end
