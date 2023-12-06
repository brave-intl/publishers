require "uri"
require "net/http"

module Gemini
  class GetValidationService < ::Payout::Service
    DOCUMENT_PRIORITY = %w[passport drivers_license national_identity_card passport_card]

    def self.perform(gemini_connection, verification_token)
      result = perform_get(gemini_connection, verification_token)
      if result["validDocuments"].present?
        valid_documents = result["validDocuments"]
        valid_documents.min_by { |vd| DOCUMENT_PRIORITY.index(vd["type"]) }["issuingCountry"]
      elsif result["countryCode"].present?
        result["countryCode"]
      end
    end

    def self.perform_get(gemini_connection, verification_token)
      params = {"token" => verification_token, "recipient_id" => gemini_connection.recipient_id}

      uri = URI("#{Gemini.api_base_uri}v1/account/validate")
      uri.query = URI.encode_www_form(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = "Bearer #{gemini_connection.access_token}"

      response = http.request(request)
      # Something like
      # {"id"=>"1234", "countryCode"=>"us", "validDocuments"=>[{"type"=>"drivers_license", "issuingCountry"=>"US"}]}
      # or
      # {"id"=>"312fde", "countryCode"=>"in", "validDocuments"=>[{"type"=>"passport", "issuingCountry"=>"IN"}, {"type"=>"national_identity_card", "issuingCountry"=>"IN"}, {"type"=>"national_identity_card", "issuingCountry"=>"IN"}]}
      # or
      # {"error"=>"Unable to find any Legal Id information for the given user"}
      # or Exception for 401
      parsed_result = JSON.parse(response.body)
      if parsed_result["error"]
        {}
      else
        parsed_result
      end
    rescue Faraday::UnauthorizedError
      {"error" => "Could not find validation information for this connection."}
    end
  end
end
