class PublishersController < ApplicationController
  # Number of requests to #create before we present a captcha.
  THROTTLE_THRESHOLD_CREATE = 3
  THROTTLE_THRESHOLD_CREATE_AUTH_TOKEN = 3

  include PublishersHelper

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
               resend_email_verify_email)
  before_action :require_unauthenticated_publisher,
    only: %i(sign_up
             create
             create_auth_token
             new
             new_auth_token)
  before_action :require_verified_email,
    only: %i(email_verified
             complete_signup)
  before_action :require_verified_publisher,
    only: %i(edit_payment_info
             generate_statement
             home
             statement
             statement_ready
             update
             uphold_status
             uphold_verified)
  before_action :prompt_for_two_factor_setup,
    only: %i(home)

  def sign_up
    @publisher = Publisher.new(email: params[:email])
  end

  def create
    email = params[:email]

    if email.blank?
      flash[:warning] = t(".missing_email")
      return redirect_to sign_up_publishers_path
    end

    @publisher = Publisher.new(pending_email: email)

    @should_throttle = should_throttle_create? || params[:captcha]
    throttle_legit =
      @should_throttle ?
        verify_recaptcha(model: @publisher)
        : true

    unless throttle_legit
      return redirect_to root_path(captcha: params[:captcha]), alert: t(".access_throttled")
    end

    verified_publisher = Publisher.by_email_case_insensitive(email).first
    if verified_publisher
      @publisher = verified_publisher
      PublisherLoginLinkEmailer.new(email: email).perform
      flash.now[:alert] = t(".email_already_active", email: email)
      render :create_auth_token
    elsif @publisher.save
      PublisherMailer.verify_email(@publisher).deliver_later
      PublisherMailer.verify_email_internal(@publisher).deliver_later if PublisherMailer.should_send_internal_emails?
      session[:created_publisher_id] = @publisher.id
      redirect_to create_done_publishers_path
    else
      Rails.logger.error("Create publisher errors: #{@publisher.errors.full_messages}")
      flash[:warning] = t(".invalid_email")
      redirect_to sign_up_publishers_path
    end
  end

  def create_done
    @publisher = Publisher.find(session[:created_publisher_id])
    @publisher_email = @publisher.pending_email
  end

  def resend_email_verify_email
    @publisher = Publisher.find(session[:created_publisher_id])

    PublisherMailer.verify_email(@publisher).deliver_later
    PublisherMailer.verify_email_internal(@publisher).deliver_later if PublisherMailer.should_send_internal_emails?

    session[:created_publisher_id] = @publisher.id
    redirect_to create_done_publishers_path, alert: t(".done")
  end

  def email_verified
    @publisher = current_publisher
  end

  def complete_signup
    @publisher = current_publisher
    update_params = publisher_complete_signup_params

    if @publisher.agreed_to_tos.nil?
      update_params[:agreed_to_tos] = Time.now
    end

    if @publisher.update(update_params)
      # let eyeshade know about the new Publisher
      begin
        PublisherChannelSetter.new(publisher: @publisher).perform
      rescue => e
        require "sentry-raven"
        Raven.capture_exception(e)
      end

      redirect_to publisher_next_step_path(@publisher)
    else
      render(:email_verified)
    end
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
      PublisherMailer.notify_email_change(publisher).deliver_later
      PublisherMailer.confirm_email_change(publisher).deliver_later
      PublisherMailer.confirm_email_change_internal(publisher).deliver_later if PublisherMailer.should_send_internal_emails?
    end

    respond_to do |format|
      format.json {
        if success
          head :no_content
        else
          render(json: { errors: publisher.errors }, status: 400)
        end
      }
    end
  end

  # "Magic sign in link" / One time sign-in token via email
  def new_auth_token
    @publisher = Publisher.new
  end

  def create_auth_token
    email = publisher_create_auth_token_params[:email]
    @publisher = Publisher.new(publisher_create_auth_token_params)
    @should_throttle = should_throttle_create_auth_token? || params[:captcha]
    throttle_legit =
      @should_throttle ?
        verify_recaptcha(model: @publisher)
        : true
    if !throttle_legit
      render(:new_auth_token)
      return
    end

    emailer = PublisherLoginLinkEmailer.new(email: email)

    if emailer.perform
      # Success shown in view #create_auth_token
    else
      # Failed to find publisher
      flash.now[:alert_html_safe] = t('.unfound_alert_html', {
        new_publisher_path: sign_up_publishers_path(email: email),
        create_publisher_path: publishers_path(email: email),
        email: ERB::Util.html_escape(email)
      })
      render(:new_auth_token)
    end
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

  # Entrypoint for the authenticated re-login link.
  def show
    redirect_to(publisher_next_step_path(current_publisher))
  end

  # Domain verified. See balance and submit payment info.
  def home
    # ensure the wallet has been fetched, which will check if Uphold needs to be re-authorized
    # ToDo: rework this process?
    current_publisher.wallet
  end

  def log_out
    path = after_sign_out_path_for(current_publisher)
    sign_out(current_publisher)
    redirect_to(path)
  end

  def choose_new_channel_type
  end

  def generate_statement
    publisher = current_publisher
    statement_period = params[:statement_period]
    statement = PublisherStatementGenerator.new(publisher: publisher, statement_period: statement_period.to_sym).perform
    SyncPublisherStatementJob.perform_later(publisher_statement_id: statement.id)
    render(json: {
      id: statement.id,
      date: statement_period_date(statement.created_at),
      period: statement_period_description(statement.period.to_sym)
    }, status: 200)
  end

  def statement_ready
    statement = PublisherStatement.find(params[:id])
    if statement && statement.contents
      render(nothing: true, status: 204)
    else
      render(nothing: true, status: 404)
    end
  end

  def statement
    statement = PublisherStatement.find(params[:id])

    if statement
      send_data statement.contents, filename: publisher_statement_filename(statement)
    else
      render(nothing: true, status: 404)
    end
  end

  def status
    publisher = current_publisher
    respond_to do |format|
      format.json {
        render(json: {
          status: publisher_status(publisher).to_s,
          status_description: publisher_status_description(publisher),
          timeout_message: publisher_status_timeout(publisher),
          uphold_status: publisher.uphold_status.to_s,
          uphold_status_description: uphold_status_description(publisher)
        }, status: 200)
      }
    end
  end

  def balance
    publisher = current_publisher
    respond_to do |format|
      format.json {
        render(json: {
            bat_amount: publisher_humanize_balance(current_publisher, "BAT"),
            converted_balance: publisher_converted_balance(publisher)
        }, status: 200)
      }
    end
  end

  private

  def authenticate_via_token
    sign_out(current_publisher) if current_publisher

    publisher_id = params[:id]
    token = params[:token]
    confirm_email = params[:confirm_email]

    return if publisher_id.blank? || token.blank?

    publisher = Publisher.find(publisher_id)

    if PublisherTokenAuthenticator.new(publisher: publisher, token: token, confirm_email: confirm_email).perform
      if confirm_email.present? && publisher.email == confirm_email
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
    params.require(:publisher).permit(:pending_email, :phone, :name, :default_currency, :visible)
  end

  def publisher_create_auth_token_params
    params.require(:publisher).permit(:email, :brave_publisher_id)
  end

  # If an active session is present require users to explicitly sign out
  def require_unauthenticated_publisher
    return if !current_publisher
    redirect_to(publisher_next_step_path(current_publisher), alert: t(".already_logged_in"))
  end

  def require_verified_email
    return if current_publisher.email_verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: t(".email_verification_required"))
  end

  def require_verified_publisher
    return if current_publisher.verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: t(".verification_required"))
  end

  # Level 1 throttling -- After the first two requests, ask user to
  # submit a captcha. See rack-attack.rb for throttle keys.
  def should_throttle_create?
    Rails.env.production? &&
      request.env["rack.attack.throttle_data"] &&
      request.env["rack.attack.throttle_data"]["registrations/ip"] &&
      request.env["rack.attack.throttle_data"]["registrations/ip"][:count] >= THROTTLE_THRESHOLD_CREATE
  end

  def should_throttle_create_auth_token?
    Rails.env.production? &&
      request.env["rack.attack.throttle_data"] &&
      request.env["rack.attack.throttle_data"]["created-auth-tokens/ip"] &&
      request.env["rack.attack.throttle_data"]["created-auth-tokens/ip"][:count] >= THROTTLE_THRESHOLD_CREATE_AUTH_TOKEN
  end

  def prompt_for_two_factor_setup
    return if current_publisher.two_factor_prompted_at.present? || two_factor_enabled?(current_publisher)
    current_publisher.update! two_factor_prompted_at: Time.now
    redirect_to prompt_two_factor_registrations_path
  end
end
