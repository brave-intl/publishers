# An option for domain verification.

class PublisherVerificationFileGenerator
  attr_reader :publisher

  def initialize(publisher)
    @publisher = publisher
    if !publisher.base_domain || !publisher.verification_token
      raise "Publisher doesn't have valid #base_domain and #verification_token"
    end
  end

  # NOTE: Tell user http:// is acceptable but https:// is preferred
  def generate_url
    "https://#{publisher.base_domain}/.well-known/brave-payments-verification.txt"
  end

  def generate_file_content
    <<~HEREDOC
      This is a Brave Payments publisher verification.

      Domain: #{publisher.base_domain}
      Token: #{publisher.verification_token}
    HEREDOC
  end
end
