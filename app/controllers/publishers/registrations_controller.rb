module Publishers
  class RegistrationsController < ApplicationController
    include PublishersHelper

    # Number of requests to #create before we present a captcha.
    THROTTLE_THRESHOLD_REGISTRATION = 3
    THROTTLE_THRESHOLD_RESEND_AUTHENTICATION_EMAIL = 20

    before_action :require_unauthenticated_publisher

    # Log in page
    def sign_up
      @publisher = Publisher.new(email: params[:email])
    end

    def log_in
      @publisher = Publisher.new
    end

    # Used by sign_up.html.slim.  If a user attempts to sign up with an existing email, a log in email
    # is sent to the existing user. Otherwise, a new publisher is created and a sign up email is sent.
    def create
      enforce_throttle(throttled: throttle_registration?, path: root_path(captcha: params[:captcha])) and return

      # First check if publisher with the email already exists.
      existing_publisher = Publisher.by_email_case_insensitive(params[:email]).first
      email_existing_publisher(existing_publisher) and return if existing_publisher

      # Check if an existing email unverified publisher record exists to prevent duplicating unverified publishers.
      # Requiring `email: nil` ensures we do not select a publisher with the same pending_email
      # as a publisher in the middle of the change email flow
      @publisher = Publisher.find_or_create_by(pending_email: params[:email], email: nil)
      @publisher_email = @publisher.pending_email

      if @publisher.save
        MailerServices::VerifyEmailEmailer.new(publisher: @publisher).perform

        respond_to do |format|
          format.html { render :emailed_authentication_token }
          format.json { head :ok }
        end
      else
        Rails.logger.error("Create publisher errors: #{@publisher.errors.full_messages}")
        respond_to do |format|
          format.html do
            flash[:warning] = t(".invalid_email")
            redirect_to sign_up_publishers_path
          end
          format.json { head :bad_request }
        end
      end
    end

    # This is the method that is called after the user clicks the "Log In" button
    # If the user is an existing publisher we will send them a log in link, if they are not
    # then we provide the ability to create an account by clicking the alert on the page.
    def update
      @publisher = Publisher.by_email_case_insensitive(params[:email]).first
      @publisher_email = params[:email]

      enforce_throttle(throttled: throttle_registration?, path: log_in_publishers_path) and return

      MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform

      # If the publisher doesn't exist we'll just pretend like they do
      respond_to do |format|
        format.html { render :emailed_authentication_token }
        format.json { head :ok }
      end
    end

    def expired_authentication_token
      @publisher = Publisher.find(params[:id])
    end

    # Used by emailed_authentication_token.html.slim to send a new sign up or log in access email
    # to the publisher passed through the params
    def resend_authentication_email
      @publisher = Publisher.find(params[:id])

      enforce_throttle(throttled: throttle_resend_authentication_email?, path: log_in_publishers_path) and return

      if @publisher.email.blank?
        MailerServices::VerifyEmailEmailer.new(publisher: @publisher).perform
        @publisher_email = @publisher.pending_email
      else
        @publisher_email = @publisher.email
        MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform
      end

      flash.now[:notice] = t(".done")
      render(:emailed_authentication_token)
    end

    private

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
          render json: { message: t(".access_throttled") }, status: :too_many_requests
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
