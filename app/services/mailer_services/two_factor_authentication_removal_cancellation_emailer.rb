# typed: ignore

module MailerServices
  class TwoFactorAuthenticationRemovalCancellationEmailer < BaseService
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
      return false unless publisher
      PublisherTokenGenerator.new(publisher: publisher).perform
      PublisherMailer.two_factor_authentication_removal_cancellation(publisher).deliver
    end
  end
end
