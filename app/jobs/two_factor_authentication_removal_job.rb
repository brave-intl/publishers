# typed: ignore

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
          publisher.u2f_registrations.destroy_all unless publisher.u2f_registrations.empty?
          if !publisher.channels.empty?
            publisher.channels.each do |channel|
              is_deleted = DeletePublisherChannelJob.perform_now(channel.id)
              raise ActiveRecord::Rollback unless is_deleted
            end
          end
          publisher.selected_wallet_provider.destroy if publisher.selected_wallet_provider.present?
          publisher.status_updates.create(status: PublisherStatusUpdate::LOCKED)
          two_factor_authentication_removal.update(removal_completed: true)
        end

      # Locked status waiting period completed - 6 weeks
      elsif two_factor_authentication_removal.locked_status_time_completed?
        # Return publisher to previous state.
        ActiveRecord::Base.transaction do
          if publisher.locked?
            previous_status = publisher.status_updates.find { |status_update| status_update.status != PublisherStatusUpdate::LOCKED }.status
            publisher.status_updates.create(status: previous_status)
          end

          two_factor_authentication_removal.destroy
        end
      end
    end
  end
end
