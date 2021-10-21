# frozen_string_literal: true

module Gemini
  class RecipientId < BaseApiClient
    include Initializable

    PATH = "/v1/payments/recipientIds"
    DEFAULT_LABEL = "Brave Rewards | Creators"

    # The ID generated for the creator
    attr_accessor :recipient_id
    # The provided label
    attr_accessor :label
    # "OK" or "Error"
    attr_accessor :result
    # If result is "Error", description of the cause
    attr_accessor :reason
    # Token for authorization
    attr_accessor :token

    # Public: Gets a list of all the recipient ids and searches for the label
    #         If the label doesn't exists then creates the recipient_id
    #
    # token - access token for the user
    #
    # Returns Gemini::RecipientId
    def self.find_or_create(token:, label: DEFAULT_LABEL)
      client = RecipientId.new(token: token)
      all_ids = client.all

      found = all_ids.select { |r| r.label == label }.first
      if found.blank?
        found = client.create(label: label)
      end

      found
    end

    # Public: Lists all the recipient ids, scoped to our OAuth Client ID
    #
    # token - access token for the user
    #
    # Returns a list of Gemini::RecipientId
    def self.all(token:)
      RecipientId.new(token: token).all
    end

    # Public: Creates a recipient_id
    #
    # token - access token for the user
    #
    # Returns a Gemini::RecipientId
    def self.create(token:, label: DEFAULT_LABEL)
      RecipientId.new(token: token).create(label: label)
    end

    def all
      response = get(PATH)

      JSON.parse(response.body).map do |recipient|
        Gemini::RecipientId.new(recipient)
      end
    end

    def create(label:)
      payload = {label: label}
      headers = {"X-GEMINI-PAYLOAD" => Base64.strict_encode64(payload.to_json)}

      response = post(PATH, {}, api_authorization_header, headers)

      Gemini::RecipientId.new(JSON.parse(response.body))
    end

    private

    def api_base_uri
      Gemini.api_base_uri
    end

    def api_authorization_header
      "Bearer #{token}"
    end
  end
end
