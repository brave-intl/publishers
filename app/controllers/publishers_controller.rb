# typed: ignore

class PublishersController < ApplicationController
  include PublishersHelper
  include PromosHelper
  include PendingActions

  VERIFIED_PUBLISHER_ROUTES = [
    :show,
    :home,
    :update
  ].freeze

  before_action :authenticate_via_token, only: %i[show]
  before_action :authenticate_publisher!, except: %i[ensure_email ensure_email_confirm]

  before_action :require_publisher_email_not_verified_through_youtube_auth,
    except: %i[update_email change_email]

  before_action :require_publisher_email_verified_through_youtube_auth,
    only: %i[update_email]

  before_action :protect, only: %i[show home]
  before_action :require_verified_publisher, only: VERIFIED_PUBLISHER_ROUTES
  before_action :prompt_for_two_factor_setup, only: %i[home]

  before_action :require_verified_email, only: %i[email_verified complete_signup]

  skip_around_action :switch_locale, only: [:show]

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

    if @publisher.update(update_params)
      session[:publisher_created_through_youtube_auth] = nil
      redirect_to publisher_next_step_path(@publisher)
    else
      flash[:alert] = @publisher.errors.full_messages.join(", ")
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
    update_params = publisher_update_params

    # If user enters current email address delete the pending email attribute
    update_params[:pending_email] = update_params[:pending_email]&.downcase
    update_params[:pending_email] = nil if update_params[:pending_email] == current_publisher.email

    success = current_publisher.update(update_params)

    if success && update_params[:pending_email]
      MailerServices::ConfirmEmailChangeEmailer.new(publisher: current_publisher).perform
    end

    flash[:notice] = I18n.t("publishers.settings.update.alert")
    respond_to do |format|
      if success
        format.json { render json: {} }
        format.html { redirect_to home_publishers_path }
      else
        format.json { render(json: {errors: current_publisher.errors}, status: 400) }
        format.html { render(status: 400) }
      end
    end
  end

  def protect
    if current_publisher.nil? || current_publisher.browser_user?
      redirect_to root_url and return
    elsif current_publisher.admin?
      redirect_to admin_publishers_path and return
    end
  end

  def ensure_email
    token = params[:token]
    publisher = Publisher.find(params[:id])

    if token && PublisherTokenAuthenticator.new(publisher: publisher, token: token).perform(consume: false)
      @publisher = publisher
    else
      flash[:alert] = t("shared.error")
      redirect_to expired_authentication_token_publishers_path(id: publisher.id)
    end
  end

  def ensure_email_confirm
    publisher = Publisher.find(params[:id])
    cookies[:_publisher_id] = {value: publisher.id, same_site: :lax, secure: true, httponly: true, expires: 20.year.from_now}
    redirect_to(publisher_path(publisher, params: request.request_parameters.except(:authenticity_token, :commit, :id)))
  end

  def change_email
    @publisher = current_publisher
  end

  def change_email_confirm
    @publisher = current_publisher
  end

  # Entrypoint for the authenticated re-login link.
  def show
    I18n.with_locale(japanese_http_header? ? preferred_japanese_locale : I18n.default_locale) do
      redirect_to(publisher_next_step_path(current_publisher))
    end
  end

  class DestroyPublisher < StepUpAction
    call do |publisher_id|
      current_publisher = Publisher.find(publisher_id)
      PublisherRemovalJob.perform_later(publisher_id)
      sign_out(current_publisher)
      redirect_to(root_path)
    end
  end

  def destroy
    DestroyPublisher.new(current_publisher.id).step_up! self
  end

  # Domain verified. See balance and submit payment info.
  def home
    @publisher = current_publisher

    if payout_in_progress?(current_publisher) && Date.today.day < 12 # Let's display the payout for 5 days after it should complete (on the 8th)
      @payout_report = PayoutReport.where(final: true, manual: false).order(created_at: :desc).first
    end

    @channels = @publisher.channels.visible.paginate(page: params[:page], per_page: 10)
    @publisher_unattached_promo_registrations = @publisher.promo_registrations.unattached_only

    flash[:warning] = I18n.t("publishers.home.referral_program_winddown", blog_link: "https://brave.com/referral-program-update/").html_safe if Time.now < "2020-12-01"
  end

  def home_balances
    @publisher = current_publisher
    @case = Case.find_by(publisher: current_publisher)
    render partial: "home_balances"
  end

  def uphold_wallet_panel
    @publisher = current_publisher
    @last_settlement_balance = Eyeshade::LastSettlementBalance.for_publisher(publisher: @publisher)
    render partial: "uphold_wallet_panel"
  end

  def choose_new_channel_type
  end

  def create_new_untethered_referral_code
    @publisher = current_publisher
    if @publisher.may_create_referrals?
      Promo::UnattachedRegistrar.new(number: 1,
        promo_id: "unattached_referral_pubs",
        publisher: @publisher,
        description: params["promo-name"]).perform
      flash[:notice] = "Promo code created successfully."
      redirect_to(root_path)
    end
  end

  def get_site_banner_data
    prepare_site_banner_data
    site_banners_channel_to_id = current_publisher.site_banners.map { |sb| [sb.channel_id, sb.id] }.to_h
    # This could be sped up to avoid O(n) queries against the *Details tables, but it's still indexes so it's not worth tackling quite yet
    channel_banners = current_publisher.channels.map do |channel|
      {
        id: site_banners_channel_to_id[channel.id],
        name: channel.publication_title,
        type: channel.details_type,
        url: channel.details.url
      }
    end
    data = {channel_banners: channel_banners}
    render(json: data.to_json)
  end

  private

  class SignIn < StepUpAction
    call do |publisher_id, confirm_email|
      current_publisher = Publisher.find(publisher_id).confirm_pending_email!(confirm_email)

      if confirm_email.present? && current_publisher.email == confirm_email && !publisher_created_through_youtube_auth?(current_publisher)
        flash[:notice] = t("publishers.show.email_confirmed", email: current_publisher.email)
      end

      sign_in(:publisher, current_publisher)
      redirect_to publisher_next_step_path(current_publisher) if two_factor_enabled?(current_publisher)
    end
  end

  def authenticate_via_token
    # For some odd reason, devise flash alerts get displayed during auth.
    # Deeper details can be chased in:
    # https://github.com/heartcombo/devise/blob/83a32e6d2118b0535cf54b48df4f9853d85b55fd/lib/devise/failure_app.rb
    flash[:alert] = nil
    publisher_id = params[:id]
    token = params[:token]
    confirm_email = params[:confirm_email]

    return if publisher_id.blank? || token.blank?

    publisher = Publisher.find(publisher_id)

    publisher_created_through_youtube_auth = publisher_created_through_youtube_auth?(publisher)
    if publisher_created_through_youtube_auth
      session[:publisher_created_through_youtube_auth] = publisher_created_through_youtube_auth
    end

    if !two_factor_enabled?(publisher) && cookies["_publisher_id"] && (cookies["_publisher_id"] != publisher_id)
      redirect_to(ensure_email_publisher_path(publisher, params: request.query_parameters))
      return
    end

    if PublisherTokenAuthenticator.new(publisher: publisher, token: token).perform
      SignIn.new(publisher_id, confirm_email).step_up! self
    else
      flash[:alert] = t(".token_invalid")
      redirect_to expired_authentication_token_publishers_path(id: publisher.id)
    end
  end

  def prepare_site_banner_data
    if current_publisher.channels.length.zero?
      SiteBanner.new_helper(current_publisher.id, nil)
    else
      current_publisher.channels.each do |channel|
        channel.site_banner = SiteBanner.new_helper(current_publisher.id, channel.id) if channel.site_banner.nil?
      end
    end
  end

  def publisher_complete_signup_params
    params.require(:publisher).permit(:name, :subscribed_to_marketing_emails)
  end

  def publisher_update_params
    params.require(:publisher).permit(:pending_email, :name, :subscribed_to_marketing_emails, :thirty_day_login)
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

  def require_verified_email
    return if current_publisher.email_verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: t(".email_verification_required"))
  end
end
