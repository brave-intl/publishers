module Publishers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    include PublishersHelper

    before_action :require_publisher, only: [:register_youtube_channel, :register_twitch_channel]
    before_action :require_publisher_not_created_through_youtube_auth,
                  only: %i(register_youtube_channel)

    def register_youtube_channel
      oauth_response = request.env['omniauth.auth']
      token = oauth_response.credentials.token

      youtube_channel_data = YoutubeChannelGetter.new(token: token).perform

      if youtube_channel_data.nil?
        redirect_to home_publishers_path, notice: t("shared.channel_not_found")
        return
      end

      existing_channel = Channel.joins(:youtube_channel_details).
          where("youtube_channel_details.youtube_channel_id": youtube_channel_data['id']).first

      if existing_channel && existing_channel.publisher == current_publisher
        redirect_to home_publishers_path, notice: t(".channel_already_registered")
        return
      end

      @channel = Channel.new(publisher: current_publisher, verified: true)

      youtube_details_attrs = {
        youtube_channel_id: youtube_channel_data['id'],
        title: youtube_channel_data.dig('snippet', 'title'),
        description: youtube_channel_data.dig('snippet', 'description'),
        thumbnail_url: youtube_channel_data.dig('snippet', 'thumbnails', 'default', 'url'),
        subscriber_count: youtube_channel_data.dig('statistics', 'subscriberCount'),
        auth_provider: oauth_response.provider,
        auth_user_id: oauth_response.uid,
        auth_name: oauth_response.dig('info', 'name'),
        auth_email: oauth_response.dig('info', 'email')
      }

      @channel.details = YoutubeChannelDetails.new(youtube_details_attrs)

      if existing_channel
        Channels::ContestChannel.new(channel: existing_channel, contested_by: @channel).perform

        redirect_to home_publishers_path, notice: t("shared.channel_contested")
        return
      end

      @channel.save!
      begin
        PublisherChannelSetter.new(publisher: current_publisher).perform
      rescue => e
        # ToDo: What do we do if call to eyeshade fails
        require "sentry-raven"
        Raven.capture_exception(e)
      end

      redirect_to home_publishers_path, notice: t("shared.channel_created")
      return
    end

    def register_twitch_channel
      twitch_auth_hash = request.env['omniauth.auth']
      twitch_info = twitch_auth_hash[:info]
      uid = twitch_auth_hash[:uid]

      existing_channel = Channel.joins(:twitch_channel_details).
          where("twitch_channel_details.twitch_channel_id": uid).first

      if existing_channel && existing_channel.publisher == current_publisher
        redirect_to home_publishers_path, notice: t(".channel_already_registered", { channel_title: existing_channel.details.display_name })
        return
      end

      @channel = Channel.new(publisher: current_publisher, verified: true)

      twitch_details_attrs = {
        twitch_channel_id: uid,
        thumbnail_url: twitch_info.image,
        auth_provider: twitch_auth_hash[:provider],
        auth_user_id: uid,
        display_name: twitch_info.name,
        name: twitch_info.nickname,
        email: twitch_info.email
      }

      @channel.details = TwitchChannelDetails.new(twitch_details_attrs)

      if existing_channel
        Channels::ContestChannel.new(channel: existing_channel, contested_by: @channel).perform

        redirect_to home_publishers_path, notice: t("shared.channel_contested")
        return
      end

      @channel.save!
      begin
        PublisherChannelSetter.new(publisher: current_publisher).perform
      rescue => e
        # ToDo: What do we do if call to eyeshade fails
        require "sentry-raven"
        Raven.capture_exception(e)
      end

      redirect_to home_publishers_path, notice: t("shared.channel_created")
      return
    end

    def youtube_login
      if current_publisher
        sign_out(current_publisher)
      end

      oauth_response = request.env['omniauth.auth']

      channel_details = YoutubeChannelDetails.where(auth_user_id: oauth_response.uid).
          where.not(youtube_channel_id: nil).first

      if channel_details.nil?
        redirect_to new_auth_token_publishers_path, notice: t(".channel_not_eligable_for_youtube_login")
        return
      end

      publisher = channel_details.channel.publisher

      # if publisher.email != oauth_response.dig('info', 'email')
      unless youtube_login_permitted?(channel_details.channel)
        redirect_to new_auth_token_publishers_path, notice: t(".channel_not_eligable_for_youtube_login")
        return
      end

      session['google_oauth2_credentials_token'] = oauth_response.credentials.token

      unless current_publisher
        sign_in(:publisher, publisher)
      end

      redirect_to change_email_publishers_path
    end

    def after_omniauth_failure_path_for(scope)
      publisher = current_publisher

      if publisher
        email_verified_publishers_path
      else
        '/'
      end
    end

    def register_twitter_channel
      oauth_response = request.env['omniauth.auth']
      twitter_details_attrs = {
        auth_provider: oauth_response.provider,
        auth_email: oauth_response.info.email,
        twitter_channel_id: oauth_response.uid,
        name: oauth_response.info.name,
        screen_name: oauth_response.extra.raw_info.screen_name,
        thumbnail_url: oauth_response.info.image,
        stats: {
          followers_count: oauth_response.extra.raw_info.followers_count,
          statuses_count: oauth_response.extra.raw_info.statuses_count,
          verified: oauth_response.extra.raw_info.verified,
        }
      }

      existing_channel = Channel.joins(:twitter_channel_details).
          where("twitter_channel_details.twitter_channel_id": twitter_details_attrs[:twitter_channel_id]).first

      if existing_channel && existing_channel.publisher == current_publisher
        redirect_to home_publishers_path, notice: t(".channel_already_registered", { channel_title: existing_channel.details.screen_name })
        return
      end

      @channel = Channel.new(publisher: current_publisher, verified: true)
      @channel.details = TwitterChannelDetails.new(twitter_details_attrs)      

      if existing_channel
        Channels::ContestChannel.new(channel: existing_channel, contested_by: @channel).perform

        redirect_to home_publishers_path, notice: t("shared.channel_contested")
        return
      end
      
      @channel.save!

      begin
        PublisherChannelSetter.new(publisher: current_publisher).perform
      rescue => e
        # ToDo: What do we do if call to eyeshade fails
        require "sentry-raven"
        Raven.capture_exception(e)
      end

      redirect_to home_publishers_path, notice: t("shared.channel_created")
      return
    end

    private

    def require_publisher
      return if current_publisher
      redirect_to(root_path, alert: t(".log_in_and_retry"))
    end

    def require_publisher_not_created_through_youtube_auth
      if publisher_created_through_youtube_auth?(current_publisher)
        redirect_to(home_publishers_path)
      end
    end
  end
end
