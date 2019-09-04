class PublishersController < ApplicationController
  # Number of requests to #create before we present a captcha.

  include PublishersHelper
  include PromosHelper

  VERIFIED_PUBLISHER_ROUTES = [
    :balance,
    :disconnect_uphold,
    :edit_payment_info,
    :show,
    :home,
    :statement,
    :statements,
    :update,
    :uphold_status,
    :uphold_verified,
  ].freeze

  before_action :authenticate_via_token, only: %i(show)
  before_action :authenticate_publisher!, except: %i(
    two_factor_authentication_removal
    request_two_factor_authentication_removal
    confirm_two_factor_authentication_removal
    cancel_two_factor_authentication_removal
  )
  before_action :require_publisher_email_not_verified_through_youtube_auth,
                except: %i(update_email change_email)

  before_action :require_publisher_email_verified_through_youtube_auth,
                only: %i(update_email)

  before_action :protect, only: %i(show home)
  before_action :require_verified_publisher, only: VERIFIED_PUBLISHER_ROUTES
  before_action :redirect_if_suspended, only: VERIFIED_PUBLISHER_ROUTES
  before_action :prompt_for_two_factor_setup, only: %i(home)

  before_action :require_verified_email, only: %i(email_verified complete_signup)

  def log_out
    path = after_sign_out_path_for(current_publisher)
    sign_out(current_publisher)
    redirect_to(path)
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
        return
      end
    end

    redirect_to :change_email_publishers, alert: t("publishers.change_email.login_email_taken")
  end

  def update
    if publisher_update_params[:pending_email]
      if publisher_update_params[:pending_email] == current_publisher.email
        publisher_update_params[:pending_email] = nil
      elsif publisher_update_params[:pending_email] == current_publisher.pending_email
        publisher_update_params.delete(:pending_email)
      end
    end

    success = current_publisher.update(publisher_update_params)

    if success && publisher_update_params[:pending_email]
      MailerServices::ConfirmEmailChangeEmailer.new(publisher: current_publisher).perform
    end

    flash[:notice] = I18n.t("publishers.settings.update.alert")
    respond_to do |format|
      if success
        format.json { head :no_content }
        format.html { redirect_to home_publishers_path }
      else
        format.json { render(json: { errors: current_publisher.errors }, status: 400) }
        format.html { render(status: 400) }
      end
    end
  end

  def request_two_factor_authentication_removal
    publisher = Publisher.by_email_case_insensitive(params[:email]).first
    flash[:notice] = t("publishers.two_factor_authentication_removal.request_success")
    if publisher
      if publisher.two_factor_authentication_removal.blank?
        MailerServices::TwoFactorAuthenticationRemovalRequestEmailer.new(publisher: publisher).perform
      elsif !publisher.two_factor_authentication_removal.removal_completed
        MailerServices::TwoFactorAuthenticationRemovalCancellationEmailer.new(publisher: publisher).perform
      end
    end
    redirect_to two_factor_authentication_removal_publishers_path
  end

  def cancel_two_factor_authentication_removal
    sign_out(current_publisher) if current_publisher

    publisher = Publisher.find(params[:id])
    token = params[:token]

    if PublisherTokenAuthenticator.new(publisher: publisher, token: token, confirm_email: publisher.email).perform
      publisher.two_factor_authentication_removal.destroy if publisher.two_factor_authentication_removal.present?
      flash[:notice] = t("publishers.two_factor_authentication_removal.confirm_cancel_flash")
      redirect_to(root_path)
    else
      flash[:notice] = t("publishers.shared.error")
      redirect_to(root_path)
    end
  end

  def confirm_two_factor_authentication_removal
    sign_out(current_publisher) if current_publisher

    publisher = Publisher.find(params[:id])
    token = params[:token]

    if PublisherTokenAuthenticator.new(publisher: publisher, token: token, confirm_email: publisher.email).perform
      publisher.register_for_2fa_removal if publisher.two_factor_authentication_removal.blank?
      publisher.reload
      MailerServices::TwoFactorAuthenticationRemovalReminderEmailer.new(publisher: publisher).perform
      flash[:notice] = t("publishers.two_factor_authentication_removal.confirm_login_flash")
      redirect_to(root_path)
    else
      flash[:notice] = t("publishers.shared.error")
      redirect_to(root_path)
    end
  end

  def protect
    if current_publisher.nil?
      redirect_to root_url and return
    elsif current_publisher.admin?
      redirect_to admin_publishers_path and return
    end
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

  def destroy
    PublisherRemovalJob.perform_later(publisher_id: current_publisher.id)
    sign_out(current_publisher)
    redirect_to(root_path)
  end

  def redirect_if_suspended
    # Redirect to suspended page if they're logged in
    redirect_to(suspended_error_publishers_path) and return if current_publisher.present? && current_publisher.suspended?
  end

  # Domain verified. See balance and submit payment info.
  def home
    @publisher = current_publisher
    uphold_connection = current_publisher.uphold_connection
    if uphold_connection.blank?
      uphold_connection = UpholdConnection.create!(publisher: current_publisher)
    end

    # ensure the wallet has been fetched, which will check if Uphold needs to be re-authorized
    # ToDo: rework this process?
    @wallet = current_publisher.wallet

    @case = Case.find_by(publisher: current_publisher)

    @possible_currencies = []

    @migration_present = Sidekiq::Queue.new("low").any? { |job| job.args.first.dig("job_class").eql? "MigrateUpholdAccessParametersJob" }

    if uphold_connection.uphold_details.present?
      @possible_currencies = uphold_connection.uphold_details&.currencies

      # every request to the homepage let's sync from uphold
      uphold_connection.sync_from_uphold!

      # Handles legacy case where user is missing an Uphold card
      uphold_connection.create_uphold_cards if uphold_connection.missing_card?
    end
  end

  def statements
    statement_contents = PublisherStatementGetter.new(publisher: current_publisher, statement_period: "all").perform
    @statement_has_content = statement_contents.length > 0
  end

  def choose_new_channel_type
  end

  def statement
    statement_period = params[:statement_period]
    @transactions = PublisherStatementGetter.new(publisher: current_publisher, statement_period: statement_period).perform

    if @transactions.length == 0
      redirect_to statements_publishers_path, :flash => { :alert => t("publishers.statements.no_transactions") }
    else
      @statement_period = publisher_statement_period(@transactions)
      statement_file_name = publishers_statement_file_name(@statement_period)
      statement_string = render_to_string :layout => "statement"
      send_data statement_string, filename: statement_file_name, type: "application/html"
    end
  end

  def wallet
    wallet = current_publisher.wallet

    uphold_connection = current_publisher.uphold_connection

    if wallet
      render(json: {
        wallet: wallet,
        uphold_connection: uphold_connection.as_json(only: [:default_currency], methods: :can_create_uphold_cards?),
        possible_currencies: uphold_connection.uphold_details&.currencies || [],
      })
    else
      head 404
    end
  end

  def get_site_banner_data
    prepare_site_banner_data
    default_site_banner_mode = current_publisher.default_site_banner_mode
    default_site_banner = { :id => current_publisher.default_site_banner_id, :name => "Default", :type => "Default" }
    channel_banners = current_publisher.channels.map { |channel| { id: channel.site_banner.id, name: channel.publication_title, type: channel.details_type } }
    data = { default_site_banner_mode: default_site_banner_mode, default_site_banner: default_site_banner, channel_banners: channel_banners }
    render(json: data.to_json)
  end

  private

  def authenticate_via_token
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

        flash[:notice] = t(".email_confirmed", email: publisher.email)
      end

      if two_factor_enabled?(publisher)
        session[:pending_2fa_current_publisher_id] = publisher_id
        redirect_to two_factor_authentications_path
      else
        sign_in(:publisher, publisher)
      end
    else
      flash[:alert] = t(".token_invalid")
      redirect_to expired_authentication_token_publishers_path(id: publisher.id)
    end
  end

  def prepare_site_banner_data
    if current_publisher.default_site_banner_id.nil?
      default_site_banner = SiteBanner.new_helper(current_publisher.id, nil)
      current_publisher.update(default_site_banner_id: default_site_banner.id)
    end
    if current_publisher.channels.length.zero?
      current_publisher.update(default_site_banner_mode: true)
    else
      current_publisher.channels.each do |channel|
        channel.site_banner = SiteBanner.new_helper(current_publisher.id, channel.id) if channel.site_banner.nil?
      end
    end
  end

  def publisher_complete_signup_params
    params.require(:publisher).permit(:name, :visible)
  end

  def publisher_update_params
    params.require(:publisher).permit(:pending_email, :name, :visible, :thirty_day_login)
  end

  def publisher_update_email_params
    params.require(:publisher).permit(:pending_email)
  end

  def require_verified_publisher
    return if current_publisher.verified?
    redirect_to publisher_next_step_path(current_publisher)
  end

  def require_publisher_email_not_verified_through_youtube_auth
    return unless publisher_created_through_youtube_auth?(current_publisher)
    redirect_to(change_email_publishers_path)
  end

  def require_publisher_email_verified_through_youtube_auth
    return if publisher_created_through_youtube_auth?(current_publisher)
    redirect_to(change_email_publishers_path)
  end

  def prompt_for_two_factor_setup
    return if current_publisher.two_factor_prompted_at.present? || two_factor_enabled?(current_publisher)
    current_publisher.update! two_factor_prompted_at: Time.now
    redirect_to prompt_security_publishers_path
  end

  def update_sendgrid(publisher:, prior_email: nil)
    RegisterPublisherWithSendGridJob.perform_later(publisher.id, prior_email)
  end

  def require_verified_email
    return if current_publisher.email_verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: t(".email_verification_required"))
  end
end
