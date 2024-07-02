# typed: ignore

class SiteChannelsController < ApplicationController
  include ChannelsHelper
  include PublishersHelper

  before_action :authenticate_publisher!
  before_action :setup_current_channel,
    except: %i[new update create]
  before_action :require_unverified_site,
    only: %i[
      verification_choose_method
      verification_dns_record
      verification_github
      verification_public_file
      verify
      download_verification_file
    ]
  before_action :require_https_enabled_site,
    only: %i[download_verification_file]
  before_action :require_verification_token,
    only: %i[
      verification_dns_record
      verification_public_file
      verification_github
      download_verification_file
    ]
  before_action :update_site_verification_method,
    only: %i[
      verification_dns_record
      verification_public_file
      verification_github
    ]

  before_action :require_publisher_email_not_verified_through_youtube_auth,
    only: %i[create]

  attr_reader :current_channel

  def new
    @channel = Channel.new(publisher: current_publisher, details: SiteChannelDetails.new)

    respond_to do |format|
      format.html
    end
  end

  def create
    if current_publisher.site_channel_details.count >= current_publisher.site_channel_limit
      redirect_to(home_publishers_path, {flash: {alert: I18n.t("site_channels.shared.limit")}}) && return
    end

    @current_channel = Channel.new(publisher: current_publisher)
    @current_channel.details = SiteChannelDetails.new(channel_update_unverified_params.except(:ads_enabled))
    @current_channel.details.ads_enabled_at = ActiveModel::Type::Boolean.new.cast(channel_update_unverified_params[:ads_enabled]) ? Time.now : nil
    SiteChannelDomainSetter.new(channel_details: @current_channel.details).perform

    if @current_channel.save
      redirect_to(channel_next_step_path(@current_channel), notice: t("shared.channel_created"))
    else
      if @current_channel.errors.details.key?(:brave_publisher_id)
        flash[:warning] = t(".duplicate_channel", domain: @current_channel.details.brave_publisher_id)
      end

      @channel = @current_channel
      flash.now[:warning_model_errors] = @channel.details
      render action: "new"
    end
  end

  def update
    @current_channel = current_publisher.channels.find(params[:id])
    @current_channel.details.update(ads_enabled_at: ActiveModel::Type::Boolean.new.cast(channel_update_unverified_params[:ads_enabled]) ? Time.now : nil)
  end

  def download_verification_file
    generator = SiteChannelVerificationFileGenerator.new(site_channel: current_channel)
    content = generator.generate_file_content
    send_data(content, filename: generator.filename)
  end

  def verification_github
    generator = SiteChannelVerificationFileGenerator.new(site_channel: current_channel)
    @public_file_content = generator.generate_file_content
    @public_file_name = generator.filename
  end

  def verification_public_file
    generator = SiteChannelVerificationFileGenerator.new(site_channel: current_channel)
    @public_file_content = generator.generate_file_content
    @public_file_name = generator.filename
  end

  # TODO: Rate limit
  def check_for_https
    @channel = current_channel
    @channel.details.inspect_host
    @channel.save!
    flash[:notice] = t(".alert")
    redirect_to(site_last_verification_method_path(@channel))
  end

  def verify
    SiteChannelVerifier.new(channel: current_channel).perform
    current_channel.reload
    if current_channel.verified?
      redirect_to home_publishers_path, notice: t(".success")
    elsif current_channel.verification_awaiting_admin_approval?
      redirect_to home_publishers_path, notice: t(".awaiting_admin_approval")
    elsif current_channel.verification_pending?
      redirect_to home_publishers_path, notice: t("shared.channel_contested", time_until_transfer: time_until_transfer(current_channel))
    else
      redirect_to(site_last_verification_method_path(current_channel))
    end
  end

  private

  def channel_update_unverified_params
    params.require(:channel).require(:details_attributes).permit(:brave_publisher_id_unnormalized, :ads_enabled)
  end

  def setup_current_channel
    @current_channel = current_publisher.channels.find(params[:id])
    return if current_channel && current_channel.details.is_a?(SiteChannelDetails)
    redirect_to(home_publishers_path(current_publisher), alert: t(".alert"))
  rescue ActiveRecord::RecordNotFound
    redirect_to(home_publishers_path, alert: t("shared.channel_not_found"))
  end

  def require_verification_token
    if current_channel.details.verification_token.blank?
      current_channel.details.update_attribute(:verification_token, SecureRandom.hex(32))
      current_channel.save!
    end
  end

  def require_unverified_site
    return unless current_channel.verified?
    redirect_to(channel_next_step_path(current_channel), alert: t(".alert"))
  end

  def require_https_enabled_site
    return if current_channel.details.supports_https?
    redirect_to(site_last_verification_method_path(current_channel), alert: t("site_channels.require_https_enabled_site.alert"))
  end

  def update_site_verification_method
    case params[:action]
    when "verification_dns_record"
      current_channel.details.verification_method = "dns_record"
    when "verification_public_file"
      current_channel.details.verification_method = "public_file"
    when "verification_github"
      current_channel.details.verification_method = "github"
    else
      raise "unknown action"
    end
    current_channel.details.save! if current_channel.details.verification_method_changed?
  end

  def require_publisher_email_not_verified_through_youtube_auth
    return unless publisher_created_through_youtube_auth?(current_publisher)
    redirect_to(home_publishers_path)
  end
end
