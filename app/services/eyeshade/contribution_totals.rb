class Eyeshade::ContributionTotals < Eyeshade::BaseApiClient
  def perform
    if should_cache?
      @result = read_cache
      return @result if @result.present?
    end
    if Rails.application.secrets[:api_eyeshade_offline]
      @result = perform_offline
    else
      begin
        response = connection.get do |request|
          request.headers["Authorization"] = api_authorization_header
          request.url("/v1/accounts/earnings/contributions/total")
        end
        @result = JSON.parse(response.body)
      end
    end
    update_cache if should_cache?
  end

  def perform_offline
    [
      {
        "channel"=>"youtube#channel:UC0jeQ0Y8y6n-FWZNDIRO2Ug",
        "earnings"=>"10.000000000000000000",
        "account_id"=>"publishers#uuid:a064ed75-b185-4841-aefb-7a0ed61731b2"
      }
    ]
  end

  def should_cache?
    true
  end

  def cache_key
    "contribution_totals"
  end
end

