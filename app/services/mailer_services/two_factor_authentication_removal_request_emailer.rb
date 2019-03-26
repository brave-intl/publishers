module MailerServices
    class TwoFactorAuthenticationRemovalRequestEmailer < BaseService
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
        PublisherTokenGenerator.new(publisher: publisher).perform
        PublisherMailer.two_factor_authentication_removal_request(publisher).deliver
      end
    end
  end
  