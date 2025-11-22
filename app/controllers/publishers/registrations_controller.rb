# typed: ignore

module Publishers
  class RegistrationsController < ApplicationController
    include PublishersHelper

    # Number of requests to #create before we present a captcha.
    THROTTLE_THRESHOLD_REGISTRATION = 3
    THROTTLE_THRESHOLD_RESEND_AUTHENTICATION_EMAIL = 20

    before_action :require_unauthenticated_publisher

    def expired_authentication_token
      @publisher = Publisher.where(id: params[:id]).first
      if @publisher.blank?
        flash[:notice] = "Problem processing your request, please try again."
        redirect_to root_path
      end
    end

    # Used by emailed_authentication_token.html.slim to send a new sign up or log in access email
    # to the publisher passed through the params
    def resend_authentication_email
      @publisher = Publisher.find(params[:id])

      if @publisher.email.blank?
        MailerServices::VerifyEmailEmailer.new(publisher: @publisher, locale: locale_from_header).perform
        @publisher_email = @publisher.pending_email
      else
        @publisher_email = @publisher.email
        MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform
      end

      @publisher_email = filter_email(@publisher_email)

      flash.now[:notice] = t(".done")
      render(:emailed_authentication_token)
    end

    private

    def locale_from_header
      (request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first == "ja") ? :ja : :en
    rescue
      I18n.default_locale
    end

    def filter_email(email)
      # Only keep first and last characters
      range = 1...-1
      identifier, provider = email.split("@")
      identifier.tap { |x| x[range] = ("*" * x[range].length) }
      "#{identifier}@#{provider}"
    end

    def email_existing_publisher(publisher)
      @publisher = publisher
      @publisher_email = publisher.email
      MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform
      flash.now[:notice] = t("publishers.registrations.create.email_already_active", email: @publisher_email)
      respond_to do |format|
        format.html { render :emailed_authentication_token }
        format.json { head :ok }
      end
    end

    def enforce_throttle(throttled:, path:)
      @should_throttle = throttled
      throttle_is_legit = @should_throttle ? verify_recaptcha(model: @publisher) : true
      return if throttle_is_legit

      Rails.logger.info("User has been throttled")
      respond_to do |format|
        format.html { redirect_to path, alert: t(".access_throttled") and return true }
        format.json do
          render json: {message: t(".access_throttled")}, status: :too_many_requests
        end
      end
    end

    # Level 1 throttling -- After the first two requests, ask user to
    # submit a captcha. See rack-ttack.rb for throttle keys.
    def manually_triggered_captcha?
      params[:captcha].present?
    end

    def throttle_registration?
      manually_triggered_captcha? ||
        request.env.dig("rack.attack.throttle_data", "created-auth-tokens/ip", :count).to_i >= THROTTLE_THRESHOLD_REGISTRATION
    end

    def throttle_resend_authentication_email?
      manually_triggered_captcha? ||
        request.env.dig("rack.attack.throttle_data", "resend_authentication_email/publisher_id", :count).to_i >= THROTTLE_THRESHOLD_RESEND_AUTHENTICATION_EMAIL
    end

    # If an active session is present require users to explicitly sign out
    def require_unauthenticated_publisher
      return unless current_publisher

      redirect_to(publisher_next_step_path(current_publisher))
    end
  end
end
