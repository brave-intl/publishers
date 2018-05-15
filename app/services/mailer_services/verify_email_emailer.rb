# "Magic sign in link" / One time sign-in token via email
module MailerServices
  class VerifyEmailEmailer < BaseService
    attr_accessor :error
    attr_reader :publisher

    def initialize(publisher:)
      @publisher = publisher
    end

    # Returns true if everything worked;
    # Returns false and sets #error if something didn't work.
    def perform
      send_email
    end

    def send_email
      return false if !publisher
      # Updates the authentication_token and saves the publisher
      token = PublisherTokenGenerator.new(publisher: publisher).perform

      PublisherMailer.verify_email(publisher).deliver_later

      if PublisherMailer.should_send_internal_emails?
        PublisherMailer.verify_email_internal(publisher).deliver_later
      end
    end
  end
end