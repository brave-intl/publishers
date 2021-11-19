# typed: false
module Payment
  class Client < BaseApiClient
    attr_accessor :api_base_uri, :api_authorization_header

    def initialize(params = {})
      self.api_base_uri = params[:uri]
      self.api_authorization_header = params[:authorization]
    end

    def key
      @key ||= Payment::Models::Key.new(as_json)
    end
  end
end
