# For users in the process of 2fa removal

class TwoFactorAuthenticationRemovalJob < ApplicationJob
  queue_as :low

  def perform
    two_factor_authentication_removals = TwoFactorAuthenticationRemoval.all
    two_factor_authentication_removals.each do |two_factor_authentication_removal|
      publisher = Publisher.find(two_factor_authentication_removal.publisher_id)
      # First 2 weeks of the job, send reminder e-mails
      if !two_factor_authentication_removal.two_factor_authentication_removal_time_completed?
        MailerServices::TwoFactorAuthenticationRemovalReminderEmailer.new(publisher: publisher).perform

      # 14th day of the job
      elsif two_factor_authentication_removal.two_factor_authentication_removal_time_completed? && !two_factor_authentication_removal.removal_completed?
        # Delete 2fa registrations, channels, and disconnect wallet
        publisher.totp_registration.destroy if publisher.totp_registration.present?
        publisher.u2f_registrations.destroy_all if !publisher.u2f_registrations.empty?
        publisher.channels.destroy_all if !publisher.channels.empty?
        publisher.disconnect_uphold
        PublisherWalletDisconnector.new(publisher: publisher).perform
        # Set status to Locked, mark 2fa removals as complete
        publisher.status_updates.create(status: PublisherStatusUpdate::LOCKED)
        two_factor_authentication_removal.update(removal_completed: true)

      # After 6 weeks of the job. Restore publisher to Active state, delete the two_factor_authentication_removal object.
      elsif two_factor_authentication_removal.locked_status_time_completed?
        publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE)
        two_factor_authentication_removal.destroy
      end
    end
  end
end
