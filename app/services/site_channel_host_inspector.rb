require 'publishers/fetch'

# Inspect a brave_publisher_id's host for web_host and HTTPS support
class SiteChannelHostInspector < BaseService
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
  rescue => e
    Rails.logger.warn("PublisherHostInspector #{brave_publisher_id} #inspect_uri error: #{e}")
    { response: e }
  end

  def perform
    return perform_offline if Rails.application.secrets[:host_inspector_offline]

    # test HTTPS first
    https_result = inspect_uri(URI("https://#{brave_publisher_id}"))
    if success_response?(https_result)
      return response_result(inspect_result: https_result, https: true)
    end

    # test HTTPS for www subdomain next
    https_www_result = inspect_uri(URI("https://www.#{brave_publisher_id}"))
    if success_response?(https_www_result)
      return response_result(inspect_result: https_www_result, https: true)
    elsif require_https
      return failure_result(https_result[:response])
    end

    # test HTTP last
    http_result = inspect_uri(URI("http://#{brave_publisher_id}"))
    if success_response?(http_result)
      return response_result(inspect_result: http_result, https: false, https_error: https_result[:response])
    else
      return failure_result(https_result[:response])
    end
  end

  private

  def success_response?(inspect_result)
    inspect_result[:response].is_a?(Net::HTTPSuccess)
  end

  def response_result(inspect_result:, https:, https_error: nil)
    result = { host_connection_verified: true, https: https }
    result[:https_error] = https_error_message(https_error)
    result[:web_host] = inspect_result[:web_host] if check_web_host
    result
  end

  def failure_result(error_response)
    Rails.logger.warn("PublisherHostInspector #{brave_publisher_id} #perform failure: #{error_response}")
    result  = { response: error_response, host_connection_verified: false, https: false }
    result[:https_error] = https_error_message(error_response)
    result
  end

  def https_error_message(error_response)
    case error_response
    when OpenSSL::SSL::SSLError
      error_response.to_s
    when RedirectError
      # error_response.to_s
      nil
    when Errno::ECONNREFUSED
      nil
    when Net::OpenTimeout
      nil
    else
      nil
    end
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
end
