class PublishersController < ApplicationController
  # Number of requests to #create before we present a captcha.
  THROTTLE_THRESHOLD_CREATE = 3
  THROTTLE_THRESHOLD_CREATE_AUTH_TOKEN = 3

  include PublishersHelper

  before_action :authenticate_via_token,
    only: %i(show)
  before_action :authenticate_publisher!,
    except: %i(create
               create_auth_token
               create_done
               new
               new_auth_token
               resend_email_verify_email)
  before_action :require_unauthenticated_publisher,
    only: %i(create
             create_auth_token
             new
             new_auth_token)
  before_action :require_unverified_publisher,
    only: %i(email_verified
             contact_info
             update_unverified
             verification
             verification_choose_method
             verification_dns_record
             verification_wordpress
             verification_github
             verification_public_file
             verification_support_queue
             verification_background
             verify
             download_verification_file)
  before_action :require_https_enabled_publisher,
    only: %i(download_verification_file
            )
  before_action :require_verified_publisher,
    only: %i(edit_payment_info
             generate_statement
             home
             statement
             statement_ready
             update
             uphold_status
             uphold_verified)
  before_action :update_publisher_verification_method,
    only: %i(verification_dns_record
             verification_public_file
             verification_support_queue
             verification_github
             verification_wordpress)

  def create
    if params[:email].blank?
      return redirect_to(root_path, notice: I18n.t("publishers.missing_info_provide_email") )
    end

    @publisher = Publisher.new(pending_email: params[:email])

    @should_throttle = should_throttle_create?
    throttle_legit =
      @should_throttle ?
        verify_recaptcha(model: @publisher)
        : true

    if throttle_legit
      if @publisher.save
        PublisherMailer.verify_email(@publisher).deliver_later!
        PublisherMailer.verify_email_internal(@publisher).deliver_later if PublisherMailer.should_send_internal_emails?
        session[:created_publisher_id] = @publisher.id
        redirect_to create_done_publishers_path
      else
        Rails.logger.error("Create publisher errors: #{@publisher.errors.full_messages}")
        redirect_to(root_path, notice: I18n.t("publishers.invalid_email_value") )
      end
    else
      Rails.logger.error(I18n.t("recaptcha.errors.verification_failed"))
      redirect_to(root_path, notice: I18n.t("publishers.verification_failed") )
    end
  end

  def create_done
    @publisher = Publisher.find(session[:created_publisher_id])
    @publisher_email = @publisher.pending_email
  end

  def resend_email_verify_email
    @publisher = Publisher.find(session[:created_publisher_id])

    PublisherMailer.verify_email(@publisher).deliver_later!
    PublisherMailer.verify_email_internal(@publisher).deliver_later if PublisherMailer.should_send_internal_emails?
    session[:created_publisher_id] = @publisher.id
    session[:created_publisher_email] = @publisher.pending_email
    redirect_to create_done_publishers_path, alert: t("publishers.resend_confirmation_email_done")
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
      PublisherMailer.notify_email_change(publisher).deliver_later!
      PublisherMailer.confirm_email_change(publisher).deliver_later!
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

  def update_unverified
    @publisher = current_publisher
    success = @publisher.update(publisher_update_unverified_params)
    if success
      redirect_to(publisher_next_step_path(@publisher))
    else
      render(:contact_info)
    end
  end

  # "Magic sign in link" / One time sign-in token via email
  def new_auth_token
    @publisher = Publisher.new
  end

  def create_auth_token
    @publisher = Publisher.new(publisher_create_auth_token_params)
    @should_throttle = should_throttle_create_auth_token?
    throttle_legit =
      @should_throttle ?
        verify_recaptcha(model: @publisher)
        : true
    if !throttle_legit
      render(:new_auth_token)
      return
    end

    emailer = PublisherLoginLinkEmailer.new(
      brave_publisher_id: publisher_create_auth_token_params[:brave_publisher_id],
      email: publisher_create_auth_token_params[:email]
    )
    if emailer.perform
      # Success shown in view #create_auth_token
    else
      flash.now[:alert] = emailer.error
      render(:new_auth_token)
    end
  end

  # User can move forward or will be contacted
  def verification
  end

  # Explains how to verify and has button to check
  def verification_dns_record
  end

  # Verification method
  def verification_choose_method
  end

  def verification_support_queue
  end

  def verification_public_file
    generator = PublisherVerificationFileGenerator.new(publisher: current_publisher)
    @public_file_content = generator.generate_file_content
  end

  def verification_github
    generator = PublisherVerificationFileGenerator.new(publisher: current_publisher)
    @public_file_content = generator.generate_file_content
  end

  def verification_wordpress
    if !current_publisher.brave_publisher_id || !current_publisher.verification_token
      raise "Publisher doesn't have valid #brave_publisher_id and #verification_token"
    end
  end

  def email_verified
    if session[:taken_youtube_channel_id]
      @taken_youtube_channel = YoutubeChannel.find(session[:taken_youtube_channel_id])
      session[:taken_youtube_channel_id] = nil
    end
    @publisher = current_publisher
  end

  def contact_info
    @publisher = current_publisher
  end

  # Tied to button on verification_dns_record
  # Call to Eyeshade to perform verification
  # TODO: Rate limit
  # TODO: Support XHR
  def verify
    @publisher = current_publisher
    require "faraday"
    PublisherVerifier.new(
      brave_publisher_id: current_publisher.brave_publisher_id,
      publisher: current_publisher
    ).perform
    current_publisher.reload
    if current_publisher.verified?
      redirect_to(home_publishers_path)
    else
      render(:verification_background)
    end
  rescue PublisherVerifier::VerificationIdMismatch
    redirect_to(publisher_last_verification_method_path(@publisher), alert: t("activerecord.errors.models.publisher.attributes.brave_publisher_id.taken"))
  rescue Faraday::Error
    redirect_to(publisher_last_verification_method_path(@publisher), alert: t("shared.api_error"))
  end

  # TODO: Rate limit
  def check_for_https
    @publisher = current_publisher
    @publisher.inspect_brave_publisher_id
    @publisher.save!
    redirect_to(publisher_last_verification_method_path(@publisher), alert: t("publishers.https_inspection_complete"))
  end

  def uphold_verified
    @publisher = current_publisher

    # Ensure the uphold_state_token has been set. If not send back to try again
    if @publisher.uphold_state_token.blank?
      redirect_to(publisher_next_step_path(@publisher), alert: I18n.t("publishers.verification_uphold_state_token_does_not_match"))
      return
    end

    # Catch uphold errors
    uphold_error = params[:error]
    if uphold_error.present?
      Rails.logger.error("Uphold Error: #{uphold_error}-> #{params[:error_description]}")
      redirect_to(publisher_next_step_path(@publisher), alert: I18n.t("publishers.verification_uphold_error"))
      return
    end

    # Ensure the state token from Uphold matches the uphold_state_token last sent to uphold. If not send back to try again
    state_token = params[:state]
    if @publisher.uphold_state_token != state_token
      redirect_to(publisher_next_step_path(@publisher), alert: I18n.t("publishers.verification_uphold_state_token_does_not_match"))
      return
    end

    @publisher.receive_uphold_code(params[:code])

    begin
      ExchangeUpholdCodeForAccessTokenJob.perform_now(publisher_id: @publisher.id)
      @publisher.reload
    rescue Faraday::Error
      Rails.logger.error("Unable to exchange Uphold access token with eyeshade")
      redirect_to(publisher_next_step_path(@publisher), alert: I18n.t("publishers.verification_uphold_error"))
      return
    end

    redirect_to(publisher_next_step_path(@publisher))
  end

  def download_verification_file
    generator = PublisherVerificationFileGenerator.new(publisher: current_publisher)
    content = generator.generate_file_content
    send_data(content, filename: generator.filename)
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
    return if params[:id].blank? || params[:token].blank?
    publisher = Publisher.find(params[:id])
    if PublisherTokenAuthenticator.new(publisher: publisher, token: params[:token], confirm_email: params[:confirm_email]).perform
      if params[:confirm_email].present? && publisher.email == params[:confirm_email]
        flash[:alert] = t("publishers.email_confirmed", email: publisher.email)
      end
      sign_in(:publisher, publisher)
    else
      flash[:alert] = I18n.t("publishers.authentication_token_invalid")
    end
  end

  # Used by #create_auth_token
  # Kinda copied from Publisher #normalize_brave_publisher_id
  def normalize_brave_publisher_id(brave_publisher_id)
    require "faraday"
    PublisherDomainNormalizer.new(domain: brave_publisher_id).perform
  rescue PublisherDomainNormalizer::DomainExclusionError
    "#{I18n.t('activerecord.errors.models.publisher.attributes.brave_publisher_id.exclusion_list_error')} #{Rails.application.secrets[:support_email]}"
  rescue PublisherDomainNormalizer::OfflineNormalizationError => e
    e.message
  rescue Faraday::Error
    I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.api_error_cant_normalize")
  rescue URI::InvalidURIError
    I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.invalid_uri")
  end

  def publisher_update_params
    params.require(:publisher).permit(:pending_email, :phone, :name, :show_verification_status, :default_currency)
  end

  def publisher_update_unverified_params
    params.require(:publisher).permit(:brave_publisher_id, :name, :phone, :show_verification_status)
  end

  def publisher_create_auth_token_params
    params.require(:publisher).permit(:email, :brave_publisher_id)
  end

  # If an active session is present require users to explicitly sign out
  def require_unauthenticated_publisher
    return if !current_publisher
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.already_logged_in"))
  end

  def require_unverified_publisher
    return if !current_publisher.verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.verification_already_done"))
  end

  def require_https_enabled_publisher
    return if current_publisher.supports_https?
    redirect_to(publisher_last_verification_method_path(current_publisher), alert: t("publishers.requires_https"))
  end

  def require_verified_publisher
    return if current_publisher.verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.verification_required"))
  end

  def update_publisher_verification_method
    case params[:action]
    when "verification_dns_record"
      current_publisher.verification_method = "dns_record"
    when "verification_public_file"
      current_publisher.verification_method = "public_file"
    when "verification_github"
      current_publisher.verification_method = "github"
    when "verification_wordpress"
      current_publisher.verification_method = "wordpress"
    when "verification_support_queue"
      current_publisher.verification_method = "support_queue"
    end
    current_publisher.save! if current_publisher.verification_method_changed?
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
end
