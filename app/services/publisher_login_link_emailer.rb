# "Magic sign in link" / One time sign-in token via email
class PublisherLoginLinkEmailer < BaseService
  attr_accessor :error
  attr_reader :brave_publisher_id, :normal_publisher_id, :email, :publisher

  def initialize(brave_publisher_id:, email:)
    @brave_publisher_id = brave_publisher_id
    @email = email.presence
  end

  # Returns true if everything worked;
  # Returns false and sets #error if something didn't work.
  def perform
    normalize_brave_publisher_id \
      && find_publisher \
      && send_email
  end

  def normalize_brave_publisher_id
    require "faraday"
    @normal_publisher_id = PublisherDomainNormalizer.new(
      domain: brave_publisher_id
    ).perform
  rescue PublisherDomainNormalizer::DomainExclusionError, Faraday::Error
    @error = I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.api_error_cant_normalize")
    false
  rescue URI::InvalidURIError
    @error = I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.invalid_uri")
    false
  end

  def find_publisher
    publisher_verified = Publisher.find_by(brave_publisher_id: brave_publisher_id, verified: true)
    if publisher_verified
      # For verified publishers, email can be blank.
      if !email || publisher_verified.email == email
        @publisher = publisher_verified
        return true
      else
        @error = I18n.t("publishers.new_auth_token_wrong_email_publisher_verified")
        return false
      end
    end

    publishers_not_verified = Publisher.where(
      brave_publisher_id: brave_publisher_id,
      verified: false
    )
    if publishers_not_verified.none?
      @error = I18n.t("publishers.new_auth_token_publisher_not_found")
      return false
    end

    publisher_most_recent = publishers_not_verified.order("created_at DESC").first
    if publisher_most_recent.email == email
      @publisher = publisher_most_recent
      true
    else
      @error = I18n.t("publishers.new_auth_token_wrong_email_publisher_not_verified")
      false
    end
  end

  def send_email
    return false if !publisher
    PublisherMailer.login_email(publisher).deliver_later!
  end
end
