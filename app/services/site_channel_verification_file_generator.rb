# An option for domain verification.

class SiteChannelVerificationFileGenerator < BaseService
  attr_reader :site_channel

  def initialize(site_channel:)
    @site_channel = site_channel
    if !site_channel.details.brave_publisher_id || !site_channel.details.verification_token
      raise "Channel doesn't have valid #brave_publisher_id and #verification_token"
    end
  end

  def filename
    "brave-payments-verification.txt"
  end

  # NOTE: Tell user http:// is acceptable but https:// is preferred
  def generate_url
    "https://#{site_channel.details.brave_publisher_id}/.well-known/#{filename}"
  end

  def generate_file_content
    <<~HEREDOC
      This is a Brave Payments publisher verification file.

      Domain: #{site_channel.details.brave_publisher_id}
      Token: #{site_channel.details.verification_token}
    HEREDOC
  end
end
