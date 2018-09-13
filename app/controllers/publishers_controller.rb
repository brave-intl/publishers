class PublishersController < ApplicationController
  # Number of requests to #create before we present a captcha.
  THROTTLE_THRESHOLD_CREATE = 3
  THROTTLE_THRESHOLD_CREATE_AUTH_TOKEN = 3
  THROTTLE_THRESHOLD_RESEND_AUTH_EMAIL = 3

  include PublishersHelper
  include PromosHelper

  VERIFIED_PUBLISHER_ROUTES = [
    :balance,
    :disconnect_uphold,
    :edit_payment_info,
    :generate_statement,
    :home,
    :statement,
    :statement_ready,
    :statements,
    :update,
    :uphold_status,
    :uphold_verified]

  before_action :authenticate_via_token,
    only: %i(show)
  before_action :authenticate_publisher!,
    except: %i(sign_up
               create
               create_auth_token
               create_done
               new
               new_auth_token
               expired_auth_token
               resend_auth_email)
  before_action :require_unauthenticated_publisher,
    only: %i(sign_up
             create
             create_auth_token
             new
             new_auth_token)
  before_action :require_verified_email,
    only: %i(email_verified
             complete_signup)
  before_action :require_publisher_email_not_verified_through_youtube_auth,
    except: %i(update_email
               change_email)
  before_action :require_publisher_email_verified_through_youtube_auth,
                only: %i(update_email)
  before_action :protect, only: %i(show home)
  before_action :require_verified_publisher, only: VERIFIED_PUBLISHER_ROUTES
  before_action :redirect_if_suspended, only: VERIFIED_PUBLISHER_ROUTES
  before_action :prompt_for_two_factor_setup,
    only: %i(home)

  def sign_up
    @publisher = Publisher.new(email: params[:email])
  end

  # Used by sign_up.html.slim.  If a user attempts to sign up with an existing email, a log in email
  # is sent to the existing user. Otherwise, a new publisher is created and a sign up email is sent.
  def create
    email = params[:email]

    if email.blank?
      flash[:warning] = t(".missing_email")
      return redirect_to sign_up_publishers_path
    end

    @should_throttle = should_throttle_create?
    throttle_legit = @should_throttle ? verify_recaptcha(model: @publisher) : true
    if !throttle_legit
      return redirect_to root_path(captcha: params[:captcha]), alert: t(".access_throttled")
    end

    # First check if publisher with the email already exists.
    existing_email_verified_publisher = Publisher.by_email_case_insensitive(email).first
    if existing_email_verified_publisher
      @publisher = existing_email_verified_publisher
      @publisher_email = existing_email_verified_publisher.email
      MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform
      flash.now[:notice] = t(".email_already_active", email: email)
      render :emailed_auth_token
    else
      # Check if an existing email unverified publisher record exists to prevent duplicating unverified publishers.
      # Requiring `email: nil` ensures we do not select a publisher with the same pending_email
      # as a publisher in the middle of the change email flow
      @publisher = Publisher.find_or_create_by(pending_email: email, email: nil)
      @publisher_email = @publisher.pending_email

      if @publisher.save
        MailerServices::VerifyEmailEmailer.new(publisher: @publisher).perform
        render :emailed_auth_token
      else
        Rails.logger.error("Create publisher errors: #{@publisher.errors.full_messages}")
        flash[:warning] = t(".invalid_email")
        redirect_to sign_up_publishers_path
      end
    end
  end

  def create_done
    @publisher = Publisher.find(session[:created_publisher_id])
    @publisher_email = @publisher.pending_email

    render :emailed_auth_token
  end

  # Used by emailed_auth_token.html.slim to send a new sign up or log in access email
  # to the publisher passed through the params
  def resend_auth_email
    @publisher = Publisher.find(params[:publisher_id])

    @should_throttle = should_throttle_resend_auth_email?
    throttle_legit = @should_throttle ? verify_recaptcha(model: @publisher) : true

    if !throttle_legit
      render(:emailed_auth_token)
      return
    end

    if @publisher.email.nil?
      MailerServices::VerifyEmailEmailer.new(publisher: @publisher).perform
      @publisher_email = @publisher.pending_email
    else
      @publisher_email = @publisher.email
      MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform
    end

    flash.now[:notice] = t(".done")
    render(:emailed_auth_token)
  end

  def email_verified
    @publisher = current_publisher
    @publisher_created_through_youtube_auth = session[:publisher_created_through_youtube_auth]
  end

  def complete_signup
    @publisher = current_publisher
    update_params = publisher_complete_signup_params

    if @publisher.agreed_to_tos.nil?
      update_params[:agreed_to_tos] = Time.now
    end

    update_sendgrid(publisher: @publisher)

    if @publisher.update(update_params)
      # let eyeshade know about the new Publisher
      begin
        PublisherChannelSetter.new(publisher: @publisher).perform
      rescue => e
        require "sentry-raven"
        Raven.capture_exception(e)
      end

      session[:publisher_created_through_youtube_auth] = nil
      redirect_to publisher_next_step_path(@publisher)
    else
      render(:email_verified)
    end
  end

  def update_email
    @publisher = current_publisher
    update_params = publisher_update_email_params

    if update_params[:pending_email].present?
      if @publisher.update(update_params)
        MailerServices::ConfirmEmailChangeEmailer.new(publisher: @publisher).perform
        @publisher_email = @publisher.pending_email
        render :create_done
        return
      end
    end

    redirect_to :change_email_publishers, alert: t("publishers.change_email.login_email_taken")
  end

  def update
    publisher = current_publisher
    update_params = publisher_update_params

    current_email = publisher.email
    pending_email = publisher.pending_email
    updated_email = update_params[:pending_email]

    if updated_email
      if updated_email == current_email
        update_params[:pending_email] = nil
      elsif updated_email == pending_email
        update_params.delete(:pending_email)
      end
    end

    success = publisher.update(update_params)

    if success && update_params[:pending_email]
      MailerServices::ConfirmEmailChangeEmailer.new(publisher: publisher).perform
    end

    respond_to do |format|
      if success
        format.json { head :no_content  }
        format.html { redirect_to home_publishers_path }
      else
        format.json { render(json: { errors: publisher.errors }, status: 400) }
        format.html { render(status: 400) }
      end
    end
  end

  def javascript_detected
    current_publisher.update(javascript_last_detected_at: Time.now)
  end

  def protect
    return redirect_to admin_publishers_path unless current_publisher.publisher?
  end

  # Records default currency preference
  # If user does not have Uphold's `cards:write` scope, we redirect to Uphold to get authorization
  # Card creation is done in #home
  def confirm_default_currency
    confirm_default_currency_params = publisher_confirm_default_currency_params
    selected_currency = confirm_default_currency_params[:default_currency]

    current_publisher.default_currency_confirmed_at = Time.now
    current_publisher.save!

    default_currency_changed = current_publisher.default_currency != selected_currency

    if default_currency_changed
      current_publisher.default_currency = selected_currency
      current_publisher.save!

      UploadDefaultCurrencyJob.perform_now(publisher_id: current_publisher.id)
    end

    # Check if the publisher is currently missing the ability to create cards
    publisher_missing_write_scope = current_publisher.wallet.scope.exclude? "cards:write"

    if publisher_missing_write_scope
      # Redirect the publisher to Uphold in order to authorize card creation.
      # Card will be created in #home when they return.
      render(json: {
        action: 'redirect',
        status: t("publishers.confirm_default_currency_modal.redirecting"),
        redirectURL: uphold_authorization_endpoint(current_publisher),
        timeout: 3000
      }, status: 200)
    else
      create_uphold_card_for_default_currency_if_needed

      render(json: {
        action: 'refresh',
        status: t("publishers.confirm_default_currency_modal.refreshing"),
        timeout: 2000
      }, status: 200)
    end
  end

  # Log in page
  def new_auth_token
    @publisher = Publisher.new
  end

  # Used by new_auth_token.html.slim to send a log in link to an existing publisher
  def create_auth_token
    @publisher_email = publisher_create_auth_token_params[:email].downcase

    if @publisher_email.blank?
      flash[:warning] = t(".missing_email")
      return redirect_to new_auth_token_publishers_path
    end

    @should_throttle = should_throttle_create_auth_token?
    throttle_legit = @should_throttle ? verify_recaptcha(model: @publisher) : true
    if !throttle_legit
      render(:new_auth_token)
      return
    end

    @publisher = Publisher.where(email: @publisher_email).take

    if @publisher
      MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform
    else
      # Failed to find publisher
      flash.now[:alert_html_safe] = t('publishers.emailed_auth_token.unfound_alert_html', {
        new_publisher_path: sign_up_publishers_path(email: @publisher_email),
        create_publisher_path: publishers_path(email: @publisher_email),
        email: ERB::Util.html_escape(@publisher_email)
      })
      new_auth_token
      render(:new_auth_token)
      return
    end

    render :emailed_auth_token
  end

  def expired_auth_token
    @publisher = Publisher.find(params[:publisher_id])
    if @publisher.verified?
      return
    end

    redirect_to(root_path, alert: t(".expired_error"))
  end

  def uphold_verified
    @publisher = current_publisher

    # Ensure the uphold_state_token has been set. If not send back to try again
    if @publisher.uphold_state_token.blank?
      redirect_to(publisher_next_step_path(@publisher), alert: t(".uphold_error"))
      return
    end

    # Catch uphold errors
    uphold_error = params[:error]
    if uphold_error.present?
      Rails.logger.error("Uphold Error: #{uphold_error}-> #{params[:error_description]}")
      redirect_to(publisher_next_step_path(@publisher), alert: t(".uphold_error"))
      return
    end

    # Ensure the state token from Uphold matches the uphold_state_token last sent to uphold. If not send back to try again
    state_token = params[:state]
    if @publisher.uphold_state_token != state_token
      redirect_to(publisher_next_step_path(@publisher), alert: t(".uphold_error"))
      return
    end

    @publisher.receive_uphold_code(params[:code])

    begin
      ExchangeUpholdCodeForAccessTokenJob.perform_now(publisher_id: @publisher.id)
      @publisher.reload
    rescue Faraday::Error
      Rails.logger.error("Unable to exchange Uphold access token with eyeshade")
      redirect_to(publisher_next_step_path(@publisher), alert: t(".uphold_error"))
      return
    end

    redirect_to(publisher_next_step_path(@publisher))
  end

  def disconnect_uphold
    publisher = current_publisher
    publisher.disconnect_uphold
    DisconnectUpholdJob.perform_later(publisher_id: publisher.id)

    head :no_content
  end

  def change_email
    @publisher = current_publisher
  end

  def change_email_confirm
    @publisher = current_publisher
  end

  # Entrypoint for the authenticated re-login link.
  def show
    redirect_to(publisher_next_step_path(current_publisher))
  end

  def redirect_if_suspended
    # Redirect to suspended page if they're logged in
    redirect_to(suspended_error_publishers_path) and return if current_publisher.present? && current_publisher.suspended?
  end

  # Domain verified. See balance and submit payment info.
  def home
    if current_publisher.promo_stats_status == :update
      SyncPublisherPromoStatsJob.perform_later(publisher: current_publisher)
    end
    # ensure the wallet has been fetched, which will check if Uphold needs to be re-authorized
    # ToDo: rework this process?
    current_publisher.wallet

    create_uphold_card_for_default_currency_if_needed
  end

  def statements
  end

  def log_out
    path = after_sign_out_path_for(current_publisher)
    sign_out
    redirect_to(path)
  end

  def choose_new_channel_type
  end

  def generate_statement
    publisher = current_publisher
    statement_period = params[:statement_period]
    statement = PublisherStatementGenerator.new(publisher: publisher, statement_period: statement_period.to_sym).perform
    SyncPublisherStatementJob.perform_later(publisher_statement_id: statement.id, send_email: true)
    render(json: {
      id: statement.id,
      date: statement_period_date(statement.created_at),
      period: statement_period_description(statement.period.to_sym)
    }, status: 200)
  end

  def statement_ready
    statement = PublisherStatement.find(params[:id])
    if statement && statement.contents
      head 204
    else
      head 404
    end
  end

  def statement
    statement = PublisherStatement.find(params[:id])

    if statement
      send_data statement.contents, filename: publisher_statement_filename(statement)
    else
      head 404
    end
  end

  def uphold_status
    publisher = current_publisher
    respond_to do |format|
      format.json {
        render(json: {
          uphold_status: publisher.uphold_status.to_s,
          uphold_status_summary: uphold_status_summary(publisher),
          uphold_status_description: uphold_status_description(publisher),
          uphold_status_class: uphold_status_class(publisher)
        }, status: 200)
      }
    end
  end

  def balance
    wallet = current_publisher.wallet
    if wallet
      json = JsonBuilders::WalletJsonBuilder.new(publisher: current_publisher, wallet: wallet).build
      render(json: json, status: :ok)
    else
      head 404
    end
  end

  private

  def create_uphold_card_for_default_currency_if_needed
    if current_publisher.can_create_uphold_cards? &&
      current_publisher.default_currency_confirmed_at.present? &&
      current_publisher.wallet.available_currencies.exclude?(current_publisher.default_currency)

      CreateUpholdCardsJob.perform_now(publisher_id: current_publisher.id)
    end
  end

  def authenticate_via_token
    sign_out(current_publisher) if current_publisher

    publisher_id = params[:id]
    token = params[:token]
    confirm_email = params[:confirm_email]

    return if publisher_id.blank? || token.blank?

    publisher = Publisher.find(publisher_id)
    publisher_created_through_youtube_auth = publisher_created_through_youtube_auth?(publisher)
    if publisher_created_through_youtube_auth
      session[:publisher_created_through_youtube_auth] = publisher_created_through_youtube_auth
    end

    if confirm_email.present?
      prior_email = publisher.email
    end

    if PublisherTokenAuthenticator.new(publisher: publisher, token: token, confirm_email: confirm_email).perform
      if confirm_email.present? && publisher.email == confirm_email && !publisher_created_through_youtube_auth
        # Register the new email address with sendgrid, and clear the publisher interests on the old member
        update_sendgrid(publisher: publisher, prior_email: prior_email)

        flash[:alert] = t(".email_confirmed", email: publisher.email)
      end

      if two_factor_enabled?(publisher)
        session[:pending_2fa_current_publisher_id] = publisher_id
        redirect_to two_factor_authentications_path
      else
        sign_in(:publisher, publisher)
      end
    else
      flash[:alert] = t(".token_invalid")
    end
  end

  def publisher_complete_signup_params
    params.require(:publisher).permit(:name, :visible)
  end

  def publisher_update_params
    params.require(:publisher).permit(:pending_email, :phone, :name, :visible)
  end

  def publisher_update_email_params
    params.require(:publisher).permit(:pending_email)
  end

  def publisher_confirm_default_currency_params
    params.require(:publisher).permit(:default_currency)
  end

  def publisher_create_auth_token_params
    params.require(:publisher).permit(:email, :brave_publisher_id)
  end

  # If an active session is present require users to explicitly sign out
  def require_unauthenticated_publisher
    return if !current_publisher
    redirect_to(publisher_next_step_path(current_publisher))
  end

  def require_verified_email
    return if current_publisher.email_verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: t(".email_verification_required"))
  end

  def require_verified_publisher
    return if current_publisher.verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: t(".verification_required"))
  end

  def require_publisher_email_not_verified_through_youtube_auth
    return unless publisher_created_through_youtube_auth?(current_publisher)
    redirect_to(change_email_publishers_path)
  end

  def require_publisher_email_verified_through_youtube_auth
    return if publisher_created_through_youtube_auth?(current_publisher)
    redirect_to(change_email_publishers_path)
  end

  # Level 1 throttling -- After the first two requests, ask user to
  # submit a captcha. See rack-attack.rb for throttle keys.
  def should_throttle_create?
    manually_triggered_captcha? ||
    request.env["rack.attack.throttle_data"] &&
    request.env["rack.attack.throttle_data"]["registrations/ip"] &&
    request.env["rack.attack.throttle_data"]["registrations/ip"][:count] >= THROTTLE_THRESHOLD_CREATE
  end

  def should_throttle_create_auth_token?
    manually_triggered_captcha? ||
    request.env["rack.attack.throttle_data"] &&
    request.env["rack.attack.throttle_data"]["created-auth-tokens/ip"] &&
    request.env["rack.attack.throttle_data"]["created-auth-tokens/ip"][:count] >= THROTTLE_THRESHOLD_CREATE_AUTH_TOKEN
  end

  def should_throttle_resend_auth_email?
    manually_triggered_captcha? ||
    request.env["rack.attack.throttle_data"] &&
    request.env["rack.attack.throttle_data"]["resend_auth_email/publisher_id"] &&
    request.env["rack.attack.throttle_data"]["resend_auth_email/publisher_id"][:count] >= THROTTLE_THRESHOLD_RESEND_AUTH_EMAIL
  end

  def manually_triggered_captcha?
    params[:captcha].present?
  end

  def prompt_for_two_factor_setup
    return if current_publisher.two_factor_prompted_at.present? || two_factor_enabled?(current_publisher)
    current_publisher.update! two_factor_prompted_at: Time.now
    redirect_to prompt_two_factor_registrations_path
  end

  def update_sendgrid(publisher:, prior_email: nil)
    RegisterPublisherWithSendGridJob.perform_later(publisher.id, prior_email)
  end
end
