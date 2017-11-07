module Publishers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      publisher = current_publisher
      oauth_response = request.env['omniauth.auth']

      refresh_eyeshade = false

      if publisher
        if publisher.auth_provider
          raise 'Google OAuth2 Error: Provider has already been set for Publisher.'
        elsif publisher.auth_user_id
          raise 'Google OAuth2 Error: UID has already been set for Publisher.'
        end

        refresh_eyeshade = true

        publisher.auth_provider = oauth_response.provider
        publisher.auth_user_id = oauth_response.uid
        publisher.auth_name = oauth_response.dig('info', 'name')
        publisher.name ||= publisher.auth_name
        publisher.auth_email = oauth_response.dig('info', 'email')

        publisher.verified = true

        publisher.save!
      else
        publisher = Publisher.where(auth_provider: oauth_response.provider, auth_user_id: oauth_response.uid).first
        unless publisher
          redirect_to('/', notice: I18n.t("youtube.account_not_found"))
          return
        end

        if publisher.auth_name != oauth_response.dig('info', 'name') || publisher.auth_email != oauth_response.dig('info', 'email')
          refresh_eyeshade = true
        end
      end

      session['google_oauth2_credentials_token'] = oauth_response.credentials.token

      unless current_publisher
        sign_in(:publisher, publisher)
      end

      # Sync the Youtube channel details
      # Doing this only after login since token refresh is not being used
      sync_result = PublisherYoutubeChannelSyncer.new(publisher: current_publisher,
                                                      token: session['google_oauth2_credentials_token']).perform

      if sync_result == :new_channel
        refresh_eyeshade = true
      end

      if refresh_eyeshade
        begin
          PublisherChannelSetter.new(publisher: publisher).perform
        rescue => e
          # ToDo: What do we do if call to eyeshade fails
          require "sentry-raven"
          Raven.capture_exception(e)
        end
      end

      if current_publisher.youtube_channel.present?
        redirect_to home_publishers_path
      else
        redirect_to '/', error: t('youtube.channel_not_found')
      end

    rescue => e
      require "sentry-raven"
      Raven.capture_exception(e)
      sign_out(current_publisher)
      redirect_to '/', notice: t('youtube.oauth_error')
    end
  end
end
