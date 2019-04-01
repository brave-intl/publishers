# For users in the process of 2fa removal
# If 2fa removal is less than 14 days old -> Send reminder e-mails
# If 2fa removal is greater than or equal to 14 days -> Remove channels and uphold information, mark as complete

class TwoFactorAuthenticationRemovalJob < ApplicationJob
  queue_as :low

  def perform
    two_factor_authentication_removals = TwoFactorAuthenticationRemoval.all
    two_factor_authentication_removals.each do |two_factor_authentication_removal|
      publisher = Publisher.find(two_factor_authentication_removal.publisher_id)
      if two_factor_authentication_removal.time_remainder > 0
        MailerServices::TwoFactorAuthenticationRemovalReminderEmailer.new(publisher: publisher).perform
      else
        publisher.totp_registration.!delete
        publisher.channels.!delete_all
        PublisherWalletDisconnector.new(publisher: publisher).perform
        publisher.status_updates.create(status: PublisherStatusUpdate::LOCKED)
      end
    end
  end
end
