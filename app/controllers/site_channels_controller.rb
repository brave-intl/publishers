class SiteChannelsController < ApplicationController
  include ChannelsHelper

  before_action :authenticate_publisher!
  before_action :setup_current_channel,
                except: %i(new
               create)
  before_action :require_unverified_site,
                only: %i(email_verified
             contact_info
             domain_status
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
  before_action :require_https_enabled_site,
                only: %i(download_verification_file)
  before_action :require_verification_token,
                only: %i(verification_dns_record
                         verification_public_file
                         verification_github
                         verification_wordpress
                         download_verification_file)
  before_action :update_site_verification_method,
                only: %i(verification_dns_record
                         verification_public_file
                         verification_support_queue
                         verification_github
                         verification_wordpress)

  attr_reader :current_channel

  def new
    @channel = Channel.new(publisher: current_publisher, details: SiteChannelDetails.new)

    respond_to do |format|
      format.html
    end
  end

  def create
    @current_channel = Channel.new(publisher: current_publisher)
    @current_channel.details = SiteChannelDetails.new(channel_update_unverified_params)
    SiteChannelDomainSetter.new(channel_details: @current_channel.details).perform

    if @current_channel.save
      # once the channel has been saved send it to eyeshade
      begin
        PublisherChannelSetter.new(publisher: current_publisher).perform
      rescue => e
        require "sentry-raven"
        Raven.capture_exception(e)
      end

      redirect_to(channel_next_step_path(@current_channel), notice: t("channel.channel_created"))
    else
      @channel = @current_channel
      render :action => "new"
    end
  end

  def update
    # current_channel.details.update(channel_update_verified_params)
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
    @channel.details.inspect_brave_publisher_id
    @channel.save!
    redirect_to(site_last_verification_method_path(@channel), alert: t("site_channels.https_inspection_complete"))
  end

  # TODO: Rate limit
  def verify
    VerifySiteChannel.perform_later(channel_id: current_channel.id)
    render(:verification_background)
  end

  private
  def channel_update_unverified_params
    params.require(:channel).require(:details_attributes).permit(:brave_publisher_id_unnormalized)
  end

  def setup_current_channel
    @current_channel = current_publisher.channels.find(params[:id])
    return if current_channel && current_channel.details.is_a?(SiteChannelDetails)
    redirect_to(home_publishers_path(current_publisher), alert: t("channel.requires_other_channel_type"))
  rescue ActiveRecord::RecordNotFound => e
    redirect_to(home_publishers_path, alert: t("channel.channel_not_found"))
  end

  def require_verification_token
    if current_channel.details.verification_token.blank?
      current_channel.details.update_attribute(:verification_token, SiteChannelTokenRequester.new(channel: current_channel).perform)
      current_channel.save!
    end
  end

  def require_unverified_site
    return if !current_channel.verified?
    redirect_to(channel_next_step_path(current_channel), alert: I18n.t("site_channels.verification_already_done"))
  end

  def require_https_enabled_site
    return if current_channel.details.supports_https?
    redirect_to(site_last_verification_method_path(current_channel.details), alert: t("publishers.requires_https"))
  end

  def update_site_verification_method
    case params[:action]
      when "verification_dns_record"
        current_channel.details.verification_method = "dns_record"
      when "verification_public_file"
        current_channel.details.verification_method = "public_file"
      when "verification_github"
        current_channel.details.verification_method = "github"
      when "verification_wordpress"
        current_channel.details.verification_method = "wordpress"
      when "verification_support_queue"
        current_channel.details.verification_method = "support_queue"
      else
        raise "unknown action"
    end
    current_channel.details.save! if current_channel.details.verification_method_changed?
  end
end
