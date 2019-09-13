module Publishers
  class TwoFactorAuthenticationsRemovalsController < ApplicationController
    include TwoFactorAuth

    def new
    end

    def create
      publisher = pending_2fa_current_publisher

      publisher.register_for_2fa_removal if publisher.two_factor_authentication_removal.blank?
      publisher.reload

      MailerServices::TwoFactorAuthenticationRemovalReminderEmailer.new(publisher: publisher).perform
      redirect_to two_factor_authentications_path, flash: { notice: t("publishers.two_factor_authentication_removal.request_success") }
    end


    def destroy
      publisher = pending_2fa_current_publisher

      publisher.two_factor_authentication_removal.destroy if publisher.two_factor_authentication_removal.present?

      redirect_to two_factor_authentications_path, flash: { notice: t("publishers.two_factor_authentication_removal.confirm_cancel_flash") }
    end
  end
end
