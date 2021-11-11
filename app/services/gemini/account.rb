# typed: ignore
# frozen_string_literal: true

module Gemini
  class Account < BaseApiClient
    include Initializable

    # For more information about how these URI templates are structured read the explaination in the RFC
    # https://github.com/sporkmonger/addressable
    # https://www.rfc-editor.org/rfc/rfc6570.txt
    PATH = Addressable::Template.new("/v1/account{/segments*}{?query*}")

    attr_accessor :account
    attr_accessor :token
    attr_reader :users

    # Public: Finds the accounts that are authorized with a token
    #
    # token - An access token obtained through the OAuth flow
    #
    # Returns a Gemini::Account
    def self.find(token:)
      Account.new(token: token).find(token: token)
    end

    def find(token:)
      response = post(PATH.expand(segments: nil))

      Gemini::Account.new(JSON.parse(response.body))
    end

    # A setter for users
    # Converts the hash of users to a Gemini::User
    def users=(users)
      @users = users.map { |u| Gemini::User.new(u) }
    end

    def api_base_uri
      Gemini.api_base_uri
    end

    def api_authorization_header
      "Bearer #{token}"
    end
  end
end
