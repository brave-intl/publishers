module MailerServices
    class TwoFactorAuthenticationRemovalReminderEmailer < BaseService
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
        remainder = publisher.two_factor_authentication_removal.time_remainder_in_days
        PublisherMailer.two_factor_authentication_removal_reminder(publisher, remainder).deliver
      end
    end
  end
  