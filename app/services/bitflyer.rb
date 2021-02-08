module Bitflyer
  @scope = "assets create_deposit_id withdraw_to_deposit_id"
  @response_type = "code"

  class << self
    attr_accessor :api_base_uri
    attr_accessor :oauth_uri
    attr_accessor :client_id
    attr_accessor :client_secret

    attr_reader :scope
    attr_reader :response_type
  end
end
