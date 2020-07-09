# frozen_string_literal: true

module Gemini
  class Account < BaseApiClient
    include Initializable

    # For more information about how these URI templates are structured read the explaination in the RFC
    # https://github.com/sporkmonger/addressable
    # https://www.rfc-editor.org/rfc/rfc6570.txt
    PATH = Addressable::Template.new("/v1/account{/segments*}{?query*}")

    attr_accessor :account
    attr_reader :users

    def self.find(token:)
      Account.new.find(token: token)
    end

    def find(token:)
      response = get(PATH.expand, {}, "Authorization: Bearer #{token}")
      Gemini::Account.new(JSON.parse(response.data))
    end

    # A setter for users
    # Converts the hash of users to a Gemini::User
    def users=(users)
      @users = users.map { |u| Gemini::User.new(u) }
    end
  end
end
