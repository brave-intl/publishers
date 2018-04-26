# "Magic sign in link" / One time sign-in token via email
module MailerServices
  class VerificationDoneEmailer < BaseService
    attr_accessor :error
    attr_reader :verified_channel

    def initialize(verified_channel)
      @verified_channel = verified_channel
    end

    # Returns true if everything worked;
    # Returns false and sets #error if something didn't work.
    def perform
      send_email
    end

    def send_email
      return false if !verified_channel || !verified_channel.publisher
      # Updates the authentication_token and saves the publisher
      token = PublisherTokenGenerator.new(publisher: verified_channel.publisher).perform

      PublisherMailer.verification_done(verified_channel, true).deliver_later

      if PublisherMailer.should_send_internal_emails?
        PublisherMailer.verification_done_internal(verified_channel).deliver_later
      end
    end
  end
end