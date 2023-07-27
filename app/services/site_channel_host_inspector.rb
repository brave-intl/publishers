# typed: true

require "publishers/fetch"

# Inspect a url's host for web_host and HTTPS support
class SiteChannelHostInspector < BaseService
  include Publishers::Fetch

  attr_reader :url, :follow_local_redirects, :follow_all_redirects, :require_https

  def initialize(url:,
    follow_local_redirects: true,
    follow_all_redirects: false,
    require_https: false,
    response_body: false)
    @url = url
    @follow_local_redirects = follow_local_redirects
    @follow_all_redirects = follow_all_redirects
    @require_https = require_https
    @response_body = response_body
  end

  # TODO: github pages can be hosted at custom domains. We should detect them, if possible.
  # TODO: perform better https test than just raising when the connection is refused?
  def inspect_uri(uri)
    response = fetch(uri: uri,
      follow_all_redirects: follow_all_redirects,
      follow_local_redirects: follow_local_redirects)

    {response: response}
  rescue => e
    Rails.logger.warn("PublisherHostInspector #{url} #inspect_uri error: #{e}")
    {response: e}
  end

  def perform
    return perform_offline if Rails.configuration.pub_secrets[:host_inspector_offline]

    # test HTTPS first
    https_result = inspect_uri(URI("https://#{url}"))
    if success_response?(https_result)
      return response_result(inspect_result: https_result, https: true)
    end

    # test HTTPS for www subdomain next
    https_www_result = inspect_uri(URI("https://www.#{url}"))
    if success_response?(https_www_result)
      return response_result(inspect_result: https_www_result, https: true)
    elsif require_https || https_www_result[:response].is_a?(NotFoundError)
      return failure_result(https_www_result[:response])
    end
    # test HTTP last
    http_result = inspect_uri(URI("http://#{url}"))
    if success_response?(http_result)
      response_result(inspect_result: http_result, https: false, https_error: https_result[:response])
    else
      # We want to pass in the https result so that the error gets properly shown to the suer
      failure_result(https_result[:response])
    end
  end

  private

  def success_response?(inspect_result)
    inspect_result[:response].is_a?(Net::HTTPSuccess)
  end

  def response_result(inspect_result:, https:, https_error: nil)
    result = {host_connection_verified: true, https: https}
    result[:https_error] = https_error_message(https_error)
    result[:web_host] = web_host(response: inspect_result[:response])
    result[:response_body] = inspect_result[:response].body if @response_body
    result
  end

  def failure_result(error_response)
    Rails.logger.warn("PublisherHostInspector #{url} #perform failure: #{error_response}")
    result = {response: error_response, host_connection_verified: false, https: false}
    result[:https_error] = https_error_message(error_response)
    result[:web_host] = web_host(response: error_response)
    result[:verification_details] = verification_details(error_response)
    result
  end

  def verification_details(error_response)
    case error_response
    when RedirectError
      "too_many_redirects"
    when Net::OpenTimeout
      "timeout"
    when NotFoundError
      if url.include? ".well-known"
        "connection_failed"
      else
        "domain_not_found"
      end
    else
      "no_https"
    end
  end

  def web_host(response: nil)
    if URI("https://#{url}").host&.end_with?(".github.io")
      "github"
    elsif (response.try(:body) || "").include?("/wp-content/")
      "wordpress"
    end
  end

  def https_error_message(error_response)
    case error_response
    when OpenSSL::SSL::SSLError
      error_response.to_s
    when RedirectError
      nil
    when Errno::ECONNREFUSED
      nil
    when Net::OpenTimeout
      nil
    end
  end

  def true?(obj)
    %w[true 1].include? obj.to_s
  end

  def perform_offline
    Rails.logger.info("PublisherHostInspector inspecting offline.")
    result = {}
    result[:host_connection_verified] = ENV["HOST_INSPECTOR_OFFLINE_VERIFIED"] ? true?(ENV["HOST_INSPECTOR_OFFLINE_VERIFIED"]) : true
    result[:https] = ENV["HOST_INSPECTOR_OFFLINE_HTTPS"] ? true?(ENV["HOST_INSPECTOR_OFFLINE_HTTPS"]) : true
    result[:web_host] = ENV["HOST_INSPECTOR_OFFLINE_WEB_HOST"]
    result
  end
end
