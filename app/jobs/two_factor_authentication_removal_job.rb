class TwoFactorAuthenticationRemovalJob < ApplicationJob
  queue_as :low

  def perform
    two_factor_authentication_removals = TwoFactorAuthenticationRemoval.all
    two_factor_authentication_removals.each do |two_factor_authentication_removal|
      publisher = Publisher.find(two_factor_authentication_removal.publisher_id)

      # First waiting period of the job - 2 weeks
      if !two_factor_authentication_removal.two_factor_authentication_removal_time_completed?
        MailerServices::TwoFactorAuthenticationRemovalReminderEmailer.new(publisher: publisher).perform

      # First waiting period completed - 14th Day
      elsif two_factor_authentication_removal.two_factor_authentication_removal_time_completed? && !two_factor_authentication_removal.removal_completed?
        # Remove 2fa registrations, remove channels, disconnect wallet, and put publisher into LOCKED state.
        ActiveRecord::Base.transaction do
          publisher.totp_registration.destroy if publisher.totp_registration.present?
          publisher.u2f_registrations.destroy_all if !publisher.u2f_registrations.empty?
          if !publisher.channels.empty?
            publisher.channels.each do |channel|
              DeletePublisherChannelJob.perform_now(channel_id: channel.id)
            end
          end
          publisher.uphold_connection.disconnect_uphold
          PublisherWalletDisconnector.new(publisher: publisher).perform
          publisher.status_updates.create(status: PublisherStatusUpdate::LOCKED)
          two_factor_authentication_removal.update(removal_completed: true)
        end

      # Locked status waiting period completed - 6 weeks
      elsif two_factor_authentication_removal.locked_status_time_completed?
        # Return publisher to ACTIVE state.
        ActiveRecord::Base.transaction do
          publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE)
          two_factor_authentication_removal.destroy
        end
      end
    end
  end
end
