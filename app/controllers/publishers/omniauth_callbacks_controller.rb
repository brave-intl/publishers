module Publishers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      oauth_response = request.env['omniauth.auth']

      refresh_eyeshade = false

      existing_publisher = Publisher.where(auth_provider: oauth_response.provider, auth_user_id: oauth_response.uid).
          where.not(youtube_channel_id: nil).first

      # The presence of a current_publisher may indicate we're attempting to attach a channel to an email verified
      # publisher OR it's an attempt to log in using oauth.
      #
      # If there's an existing publisher with the same oath credentials AND the same email this is an attempt to
      # register the same channel to effectively the same email. Instead of showing the already registered message
      # the current_publisher can be deleted and then log them in as the existing_publisher
      if existing_publisher && current_publisher && current_publisher.youtube_channel_id.nil? &&
          existing_publisher.email == current_publisher.email &&
          existing_publisher.id != current_publisher.id
        require "sentry-raven"
        Raven.capture_message("Logging user (#{oauth_response.dig('info', 'name')}) in instead as existing user with same email (#{current_publisher.email}) and oauth credentials (#{oauth_response.provider}, #{oauth_response.uid}).")
        current_publisher.destroy
        sign_out(current_publisher)
      end

      publisher = current_publisher

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
        publisher = existing_publisher

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

        session[:taken_youtube_channel_id] = e.channel_id
        redirect_to email_verified_publishers_path
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

    def after_omniauth_failure_path_for(scope)
      publisher = current_publisher

      if publisher
        email_verified_publishers_path
      else
        '/'
      end
    end
  end
end
