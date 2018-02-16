module Publishers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    include PublishersHelper

    # ToDo: rework
    before_action :require_publisher, only: [:register_youtube_channel]
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

      if existing_channel
        if existing_channel.publisher == current_publisher
          redirect_to home_publishers_path, notice: t(".channel_already_registered")
          return
        else
          redirect_to home_publishers_path, flash: { taken_channel_id: existing_channel.id }
          return
        end
      end

      @current_channel = Channel.new(publisher: current_publisher, verified: true)

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

      @current_channel.details = YoutubeChannelDetails.new(youtube_details_attrs)

      @current_channel.save

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
