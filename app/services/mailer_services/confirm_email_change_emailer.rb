# "Magic sign in link" / One time sign-in token via email
module MailerServices
  class ConfirmEmailChangeEmailer < BaseService
    attr_accessor :error
    attr_reader :publisher

    def initialize(publisher)
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

      # Notify the previous email address
      PublisherMailer.notify_email_change(publisher).deliver_later

      # Send a new login link for the user to confirm
      PublisherMailer.confirm_email_change(publisher, true).deliver_later

      if PublisherMailer.should_send_internal_emails?
        PublisherMailer.confirm_email_change_internal(publisher).deliver_later
      end
    end
  end
end