# An option for domain verification.

class PublisherVerificationFileGenerator < BaseService
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
    if !publisher.brave_publisher_id || !publisher.verification_token
      raise "Publisher doesn't have valid #brave_publisher_id and #verification_token"
    end
  end

  def filename
    "brave-payments-verification.txt"
  end

  # NOTE: Tell user http:// is acceptable but https:// is preferred
  def generate_url
    "https://#{publisher.brave_publisher_id}/.well-known/#{filename}"
  end

  def generate_file_content
    <<~HEREDOC
      This is a Brave Payments publisher verification file.

      Domain: #{publisher.brave_publisher_id}
      Token: #{publisher.verification_token}
    HEREDOC
  end
end
