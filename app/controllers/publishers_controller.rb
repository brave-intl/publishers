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
               new_auth_token)
  before_action :require_unauthenticated_publisher,
    only: %i(create
             create_auth_token
             new
             new_auth_token)
  before_action :require_unverified_publisher,
    only: %i(verification
             verification_dns_record
             verification_public_file
             verification_failed
             verify)
  before_action :require_verified_publisher,
    only: %i(edit_payment_info
             home
             update_payment_info
             verification_done)
  before_action :update_publisher_verification_method,
    only: %i(verification_dns_record
             verification_public_file)

  def new
    @publisher = Publisher.new
    @should_throttle = should_throttle_create?
  end

  def create
    @publisher = Publisher.new(publisher_create_params)
    @should_throttle = should_throttle_create?
    throttle_legit =
      @should_throttle ?
        verify_recaptcha(model: @publisher)
        : true
    if throttle_legit && @publisher.save
      # TODO: Change to #deliver_later ?
      PublisherMailer.welcome(@publisher).deliver_later!
      PublisherMailer.welcome_internal(@publisher).deliver_later if PublisherMailer.should_send_internal_emails?
      session[:created_publisher_email] = @publisher.email
      redirect_to create_done_publishers_path
    else
      render(:new)
    end
  end

  def create_done
    @publisher_email = session[:created_publisher_email]
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
  def verification_public_file
  end

  # Tied to button on verification_dns_record
  # Call to Eyeshade to perform verification
  # TODO: Rate limit
  # TODO: Support XHR
  def verify
    require "faraday"
    PublisherVerifier.new(
      brave_publisher_id: current_publisher.brave_publisher_id,
      publisher: current_publisher
    ).perform
    current_publisher.reload
    if current_publisher.verified?
      render(:verification_done)
    else
      render(:verification_failed)
    end
  rescue PublisherVerifier::VerificationIdMismatch
    @failure_reason = I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.taken")
    render(:verification_failed)
  rescue Faraday::Error
    @try_again = true
    @failure_reason = I18n.t("shared.api_error")
    render(:verification_failed)
  end

  # Shown after verification is completed to encourage users to submit
  # payment information.
  def verification_done
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
  end

  def edit_payment_info
    @publisher = current_publisher
  end

  def update_payment_info
    @publisher = current_publisher
    @publisher.assign_attributes(publisher_payment_info_params)
    if @publisher.save
      redirect_to(publisher_next_step_path(current_publisher), notice: I18n.t("publishers.bitcoin_address_updated"))
    else
      # TODO: Oops message
      render(:edit_payment_info)
    end
  end

  def log_out
    path = after_sign_out_path_for(current_publisher)
    sign_out(current_publisher)
    redirect_to(path, notice: I18n.t("publishers.logged_out"))
  end

  private

  def authenticate_via_token
    sign_out(current_publisher) if current_publisher
    return if params[:id].blank? || params[:token].blank?
    publisher = Publisher.find(params[:id])
    if PublisherTokenAuthenticator.new(publisher: publisher, token: params[:token]).perform
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
  end

  def publisher_create_params
    params.require(:publisher).permit(:email, :brave_publisher_id, :name, :phone, :show_verification_status)
  end

  def publisher_create_auth_token_params
    params.require(:publisher).permit(:email, :brave_publisher_id)
  end

  def publisher_payment_info_params
    params.require(:publisher).permit(:bitcoin_address)
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
