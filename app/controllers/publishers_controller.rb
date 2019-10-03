class PublishersController < ApplicationController
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
  ].freeze

  before_action :authenticate_via_token, only: %i(show)
  before_action :authenticate_publisher!

  before_action :require_publisher_email_not_verified_through_youtube_auth,
                except: %i(update_email change_email)

  before_action :require_publisher_email_verified_through_youtube_auth,
                only: %i(update_email)

  before_action :protect, only: %i(show home)
  before_action :require_verified_publisher, only: VERIFIED_PUBLISHER_ROUTES
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
    if publisher_update_params[:pending_email] && publisher_update_params[:pending_email].in?([current_publisher.email, current_publisher.pending_email])
      params[:publisher].delete(:pending_email)
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

  # Domain verified. See balance and submit payment info.
  def home
    @publisher = current_publisher
    uphold_connection = current_publisher.uphold_connection
    if uphold_connection.blank?
      uphold_connection = UpholdConnection.create!(publisher: current_publisher)
    end

    if payout_in_progress? && Date.today.day < 12 # Let's display the payout for 5 days after it should complete (on the 8th)
      @payout_report = PayoutReport.where(final: true, manual: false).order(created_at: :desc).first
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

  def choose_new_channel_type
  end

  def wallet
    wallet = current_publisher.wallet

    uphold_connection = current_publisher.uphold_connection

    if wallet
      render(json:
              {
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
    params.require(:publisher).permit(:pending_email, :name, :visible, :uses_stripe_for_payout, :thirty_day_login)
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

  def payout_in_progress?
    !!Rails.cache.fetch("payout_in_progress")
  end
end
