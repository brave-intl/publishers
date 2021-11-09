# typed: ignore
# "Magic sign in link" / One time sign-in token via email
module MailerServices
  class VerifyEmailEmailer < BaseService
    attr_accessor :error
    attr_reader :publisher

    def initialize(publisher:, locale: :en)
      @publisher = publisher
      @locale = locale
    end

    # Returns true if everything worked;
    # Returns false and sets #error if something didn't work.
    def perform
      send_email
    end

    def send_email
      return false unless publisher
      # Updates the authentication_token and saves the publisher
      PublisherTokenGenerator.new(publisher: publisher).perform

      PublisherMailer.verify_email(publisher: publisher, locale: @locale).deliver_later

      if PublisherMailer.should_send_internal_emails?
        PublisherMailer.verify_email_internal(publisher).deliver_later
      end
    end
  end
end
