# typed: ignore
module Publishers
  class TwoFactorAuthenticationsRemovalsController < ApplicationController
    include TwoFactorAuth
    include Logout
    include TwoFactorRegistration

    def new
    end

    def create
      publisher = saved_pending_action.publisher

      publisher.register_for_2fa_removal if publisher.two_factor_authentication_removal.blank?
      publisher.reload

      MailerServices::TwoFactorAuthenticationRemovalReminderEmailer.new(publisher: publisher).perform
      redirect_to two_factor_authentications_path, flash: {notice: t("publishers.two_factor_authentication_removal.request_success")}
    end

    def destroy
      publisher = saved_pending_action.publisher

      publisher.two_factor_authentication_removal.destroy if publisher.two_factor_authentication_removal.present?

      redirect_to two_factor_authentications_path, flash: {notice: t("publishers.two_factor_authentication_removal.confirm_cancel_flash")}
    end
  end
end
