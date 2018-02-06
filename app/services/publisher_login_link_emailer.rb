# "Magic sign in link" / One time sign-in token via email
class PublisherLoginLinkEmailer < BaseService
  attr_accessor :error
  attr_reader :email, :publisher

  def initialize(email:)
    @email = email.presence
  end

  # Returns true if everything worked;
  # Returns false and sets #error if something didn't work.
  def perform
    find_publisher && send_email
  end

  def find_publisher
    publisher_verified = Publisher.by_email_case_insensitive(email).first

    if publisher_verified
      @publisher = publisher_verified
      return true
    else
      @error = I18n.t("services.publisher_login_link_emailer.new_auth_token_wrong_email_publisher_verified")
      return false
    end
  end

  def send_email
    return false if !publisher
    PublisherMailer.login_email(publisher).deliver_later
  end
end
