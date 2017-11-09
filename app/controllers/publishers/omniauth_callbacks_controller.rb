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
      else
        publisher = Publisher.where(auth_provider: oauth_response.provider, auth_user_id: oauth_response.uid).
            where.not(youtube_channel_id: nil).first
        unless publisher
          # Create new publisher for good UX.
          # We can do this because Google provides verified contact info.
          publisher = Publisher.new(
            auth_provider: oauth_response.provider,
            auth_user_id: oauth_response.uid,
            auth_name: oauth_response.dig('info', 'name'),
            name: oauth_response.dig('info', 'name'),
            email: oauth_response.dig('info', 'email'),
            auth_email: oauth_response.dig('info', 'email'),
            verified: true
          )
          publisher.save!
        end
      end

      session['google_oauth2_credentials_token'] = oauth_response.credentials.token

      unless current_publisher
        sign_in(:publisher, publisher)
      end

      # Sync the Youtube channel details
      # Doing this only after login since token refresh is not being used
      begin
        channel_changed = PublisherYoutubeChannelSyncer.new(publisher: current_publisher,
                                                            token: session['google_oauth2_credentials_token']).perform

        if channel_changed
          refresh_eyeshade = true
        end

        current_publisher.save!

      rescue PublisherYoutubeChannelSyncer::ChannelAlreadyClaimedError => e
        require "sentry-raven"
        Raven.capture_exception(e)

        current_publisher.auth_provider = nil
        current_publisher.auth_user_id = nil
        current_publisher.auth_name = nil
        current_publisher.name = nil
        current_publisher.auth_email = nil
        current_publisher.verified = false
        current_publisher.youtube_channel = nil

        current_publisher.save!

        redirect_to email_verified_publishers_path, notice: t('youtube.channel_already_taken')
        return
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
