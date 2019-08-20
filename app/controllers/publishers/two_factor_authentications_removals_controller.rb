module Publishers
  class TwoFactorAuthenticationsRemovalsController < ApplicationController
    include TwoFactorAuth

    def new
      @two_factor_removal = pending_2fa_current_publisher.two_factor_authentication_removal
    end

    def create
      MailerServices::TwoFactorAuthenticationRemovalRequestEmailer.new(
        publisher: pending_2fa_current_publisher
      ).perform

      redirect_to two_factor_authentication_removal_publishers_path, flash: { notice: t("publishers.two_factor_authentication_removal.request_success") }
    end

    def update
      sign_out(current_publisher) if current_publisher

      publisher = Publisher.find(params[:id])
      token = params[:token]

      if PublisherTokenAuthenticator.new(publisher: publisher, token: token, confirm_email: publisher.email).perform
        publisher.register_for_2fa_removal if publisher.two_factor_authentication_removal.blank?
        publisher.reload
        MailerServices::TwoFactorAuthenticationRemovalReminderEmailer.new(publisher: publisher).perform
        flash[:notice] = t("publishers.two_factor_authentication_removal.confirm_login_flash")
      else
        flash[:notice] = t("publishers.shared.error")
      end

      redirect_to(root_path)
    end

    def destroy
      sign_out(current_publisher) if current_publisher

      publisher = Publisher.find(params[:id])
      token = params[:token]

      if PublisherTokenAuthenticator.new(publisher: publisher, token: token, confirm_email: publisher.email).perform
        publisher.two_factor_authentication_removal.destroy if publisher.two_factor_authentication_removal.present?
        flash[:notice] = t("publishers.two_factor_authentication_removal.confirm_cancel_flash")
      else
        flash[:notice] = t("publishers.shared.error")
      end

      redirect_to(root_path)
    end
  end
end
