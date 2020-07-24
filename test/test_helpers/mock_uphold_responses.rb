module MockUpholdResponses
  def stub_uphold_cards!
    stub_request(:get, /v0\/me\/cards\?q=currency:USD/).to_return(body: [].to_json)
    stub_request(:get, /v0\/me\/cards/).to_return(body: '{}')
    stub_request(:post, /v0\/me\/cards/).to_return(body: { id: '123e4567-e89b-12d3-a456-426655440000' }.to_json)
  end
end
