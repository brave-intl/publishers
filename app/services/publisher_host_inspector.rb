require 'publishers/fetch'

# Inspect a brave_publisher_id's host for web_host and HTTPS support
class PublisherHostInspector < BaseService
  include Publishers::Fetch

  attr_reader :brave_publisher_id, :follow_local_redirects, :follow_all_redirects, :require_https, :check_web_host

  def initialize(brave_publisher_id:,
                 check_web_host: true,
                 follow_local_redirects: true,
                 follow_all_redirects: false,
                 require_https: false)
    @brave_publisher_id = brave_publisher_id
    @check_web_host = check_web_host
    @follow_local_redirects = follow_local_redirects
    @follow_all_redirects = follow_all_redirects
    @require_https = require_https
  end

  # ToDo: github pages can be hosted at custom domains. We should detect them, if possible.
  # ToDo: perform better https test than just raising when the connection is refused?
  def inspect_uri(uri)
    response = fetch(uri: uri,
                     follow_all_redirects: follow_all_redirects,
                     follow_local_redirects: follow_local_redirects)

    if check_web_host
      web_host = if brave_publisher_id.include?(".github.io")
                   "github"
                 elsif response.body.include?("/wp-content/")
                   "wordpress"
                 else
                   nil
                 end
    end

    { response: response, web_host: web_host }
  rescue Publishers::Fetch::RedirectError, Publishers::Fetch::ConnectionFailedError => e
    Rails.logger.warn("PublisherHostInspector #inspect_uri error: #{e}")
    { response: e }
  end

  def perform
    return perform_offline if Rails.application.secrets[:host_inspector_offline]

    # test HTTPS first
    https_result = inspect_uri(URI("https://#{brave_publisher_id}"))
    if success_response?(https_result)
      return response_result(https_result, true)
    end

    # test HTTPS for www subdomain next
    https_www_result = inspect_uri(URI("https://www.#{brave_publisher_id}"))
    if success_response?(https_www_result)
      return response_result(https_www_result, true)
    elsif require_https
      return failure_result(https_www_result)
    end

    # test HTTP last
    http_result = inspect_uri(URI("http://#{brave_publisher_id}"))
    if success_response?(http_result)
      return response_result(http_result, false)
    else
      return failure_result(http_result)
    end
  end

  private

  def success_response?(inspect_result)
    inspect_result[:response].is_a?(Net::HTTPSuccess)
  end

  def response_result(inspect_result, https)
    result = { host_connection_verified: true, https: https }
    result[:web_host] = inspect_result[:web_host] if check_web_host
    result
  end

  def failure_result(inspect_result)
    Rails.logger.warn("PublisherHostInspector #perform failure: #{inspect_result[:response]}")
    { response: inspect_result[:response], host_connection_verified: false, https: false }
  end

  def true?(obj)
    ["true", "1"].include? obj.to_s
  end

  def perform_offline
    Rails.logger.info("PublisherHostInspector inspecting offline.")
    result = {}
    result[:host_connection_verified] = ENV["HOST_INSPECTOR_OFFLINE_VERIFIED"] ? true?(ENV["HOST_INSPECTOR_OFFLINE_VERIFIED"]) : true
    result[:https] = ENV["HOST_INSPECTOR_OFFLINE_HTTPS"] ? true?(ENV["HOST_INSPECTOR_OFFLINE_HTTPS"]) : true
    result[:web_host] = ENV["HOST_INSPECTOR_OFFLINE_WEB_HOST"]
    return result
  end

  def api_base_uri
    Rails.application.secrets[:api_ledger_base_uri]
  end
end
