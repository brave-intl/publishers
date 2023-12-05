require 'uri'
require 'net/http'

module Gemini
  class GetValidationService < Service
    def perform(gemini_connection)

      gemini_account = Gemini::Account.find(token: gemini_connection.access_token)

      params = {'token' => gemini_account.account["verificationToken"], 'recipient_id' => gemini_connection.recipient_id}

      uri = URI("#{Gemini.api_base_uri}/v1/account/validate")
      uri.query = URI.encode_www_form(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Authorization'] = "Bearer #{gemini_connection.access_token}"

      response = http.request(request)
      # Something like
      # {"id"=>"1234", "countryCode"=>"us", "validDocuments"=>[{"type"=>"drivers_license", "issuingCountry"=>"US"}]}
      JSON.parse(response.body)
    end
  end
end
