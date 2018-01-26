namespace :publishers do
  desc "Import legacy publishers"
  task :transform_legacy_data, [:commit] => [:environment] do |t, args|

    require "legacy_data"
    extend LegacyData

    unless args[:commit]
      puts "Performing a trial run. Changes will be rolled back"
    end

    def separator
      puts "------------------------------------\n"
    end

    # `totp_registrations` are a one-to-one relationship
    # A Publisher/Owner should only have one TOTP active at a time
    # If more than one per owner we won't import them automatically. Owners will be contacted and registrations will be imported
    def add_totp_registration(owner, legacy_publisher)
      totp_registration = legacy_publisher.legacy_totp_registration
      return unless totp_registration

      count_totp = LegacyData::LegacyTotpRegistration.joins(:legacy_publisher).where("legacy_publishers.email": legacy_publisher.email).count
      if count_totp > 1
        puts "Skipping totp import for #{legacy_publisher.email}. #{count_totp} records found."
        return
      end

      params = {
          encrypted_secret: totp_registration.encrypted_secret,
          encrypted_secret_iv: totp_registration.encrypted_secret_iv,
          publisher_id: owner.id,
          last_logged_in_at: totp_registration.last_logged_in_at,
          created_at: totp_registration.created_at
      }

      new_totp_registration = TotpRegistration.new(params)
      new_totp_registration.save!

      puts "Imported totp registration: #{new_totp_registration.to_json}"
    end

    # `u2f_registrations` are a one-to-many relationship
    # A Publisher/Owner may have any number of U2F keys registered. We are capable of de-duplicating U2F keys by `public_key`)
    def add_u2f_registrations(owner, legacy_publisher)
      legacy_publisher.legacy_u2f_registrations.each do |u2f_registration|
        params = {
            certificate: u2f_registration.certificate,
            key_handle: u2f_registration.key_handle,
            public_key: u2f_registration.public_key,
            counter: u2f_registration.counter,
            name: u2f_registration.name,
            publisher_id: owner.id,
            created_at: u2f_registration.created_at
        }

        new_u2f_registration = U2fRegistration.new(params)
        new_u2f_registration.save!

        puts "Imported u2f registration: #{new_u2f_registration.to_json}"
      end
    end

    def add_site_channel(owner, legacy_publisher)
      separator

      if legacy_publisher.verified?
        puts "Importing Verified site channel Id: #{legacy_publisher.id} Name: #{legacy_publisher.brave_publisher_id}"
      else
        puts "Importing Unverified site channel Id: #{legacy_publisher.id} Name: #{legacy_publisher.brave_publisher_id}"
      end

      existing_verfied_channel = Channel.joins(:site_channel_details).find_by(verified: true, "site_channel_details.brave_publisher_id": legacy_publisher.brave_publisher_id)
      if existing_verfied_channel
        puts "An existing verified channel was found for #{legacy_publisher.brave_publisher_id} - skipping"
        return
      end

      channel_params = {
          publisher_id: owner.id,
          verified: legacy_publisher.verified,
          created_at: legacy_publisher.created_at
      }

      detail_params = {
          brave_publisher_id: legacy_publisher.brave_publisher_id,
          verification_token: legacy_publisher.verification_token,
          verification_method: legacy_publisher.verification_method,
          supports_https: legacy_publisher.supports_https,
          host_connection_verified: legacy_publisher.host_connection_verified,
          detected_web_host: legacy_publisher.detected_web_host,
          created_at: legacy_publisher.created_at
      }

      new_channel = Channel.new(channel_params)
      new_channel.details = SiteChannelDetails.new(detail_params)
      new_channel.save!

      puts "Site channel created: #{new_channel.to_json(include: [:details, :publisher])}"
    end

    def add_youtube_channel(owner, legacy_publisher)
      separator

      puts "Importing youtube channel Id: #{legacy_publisher.id} Title: #{legacy_publisher.legacy_youtube_channel.title}"

      existing_verfied_channel = Channel.joins(:youtube_channel_details).find_by(verified: true, "youtube_channel_details.youtube_channel_id": legacy_publisher.youtube_channel_id)
      if existing_verfied_channel
        puts "an existing verified channel was found for #{legacy_publisher.youtube_channel_id} - skipping"
        return
      end

      channel_params = {
          publisher_id: owner.id,
          verified: legacy_publisher.verified,
          created_at: legacy_publisher.created_at
      }

      detail_params = {
          youtube_channel_id: legacy_publisher.youtube_channel_id,
          auth_provider: legacy_publisher.auth_provider,
          auth_user_id: legacy_publisher.auth_user_id,
          auth_email: legacy_publisher.auth_email,
          auth_name: legacy_publisher.auth_name,
          title: legacy_publisher.legacy_youtube_channel.title,
          description: legacy_publisher.legacy_youtube_channel.description,
          thumbnail_url: legacy_publisher.legacy_youtube_channel.thumbnail_url,
          subscriber_count: legacy_publisher.legacy_youtube_channel.subscriber_count,
          created_at: legacy_publisher.created_at
      }

      new_channel = Channel.new(channel_params)
      new_channel.details = YoutubeChannelDetails.new(detail_params)
      new_channel.save!

      puts "Youtube channel created: #{new_channel.to_json(include: [:details, :publisher])}"
    end

    puts "Going to transform #{LegacyData::LegacyPublisher.email_verified.count} email verified out of #{LegacyData::LegacyPublisher.count} legacy publishers"

    ActiveRecord::Base.transaction do
      new_owner_count = 0
      new_verified_site_channel_count = 0
      new_unverified_site_channel_count = 0
      new_youtube_channel_count = 0

      # Create or update an Owner for all verified email addresses, rolling up details
      LegacyData::LegacyPublisher.email_verified.order(created_at: :asc).each_with_index do |legacy_publisher, idx|
        separator
        puts "Importing publisher #{idx} Id: #{legacy_publisher.id} Name: #{legacy_publisher.name}"

        # Create the new owner or update an existing owner if it already exists.
        owner = Publisher.find_by(email: legacy_publisher.email)
        if owner
          puts "Found existing owner - using instead"
        else
          owner = Publisher.new(email: legacy_publisher.email)
          new_owner_count = new_owner_count + 1
        end

        params = {
            name: owner.name || legacy_publisher.name,
            phone: owner.phone || legacy_publisher.phone,
            created_via_api: owner.created_via_api || legacy_publisher.created_via_api,
            default_currency: owner.default_currency || legacy_publisher.default_currency,
            uphold_verified: owner.uphold_verified || legacy_publisher.uphold_verified,
            uphold_updated_at: owner.uphold_updated_at || legacy_publisher.uphold_updated_at,
            created_at: legacy_publisher.created_at,
            visible: owner.visible && legacy_publisher.show_verification_status
        }

        owner.update!(params)
        puts "Owner: #{owner.to_json}"

        add_u2f_registrations(owner, legacy_publisher)
        add_totp_registration(owner, legacy_publisher)
      end

      separator
      puts "Importing legacy publishers to channels"

      # Loop through all Publishers (owners) and look for legacy channels to import
      Publisher.email_verified.each_with_index do |owner, idx|
        # Create a channel for all verified Site Publishers

        LegacyData::LegacyPublisher.verified_sites(email: owner.email).each do |legacy_publisher|
          add_site_channel(owner, legacy_publisher)
          new_verified_site_channel_count = new_verified_site_channel_count + 1
        end

        # Get latest unverified Site Publishers, grouped by email and domain ordered by created_at
        unverified_sites = LegacyData::LegacyPublisher.unverified_sites(email: owner.email).group([:email, :brave_publisher_id]).pluck(:email, :brave_publisher_id, 'MAX("created_at")')

        unverified_sites.each do |unverfied_site|
          legacy_publisher = LegacyData::LegacyPublisher.find_by(email: unverfied_site[0], brave_publisher_id: unverfied_site[1], created_at: unverfied_site[2])
          add_site_channel(owner, legacy_publisher)
          new_unverified_site_channel_count = new_unverified_site_channel_count + 1
        end

        # Create a channel for each Youtube publisher
        LegacyData::LegacyPublisher.joins(:legacy_youtube_channel).verified_youtube(email: owner.email).each do |legacy_publisher|
          add_youtube_channel(owner, legacy_publisher)
          new_youtube_channel_count = new_youtube_channel_count + 1
        end
      end

      separator
      puts "#{new_owner_count} Owners created"
      puts "#{new_verified_site_channel_count} verified Site Channels created"
      puts "#{new_unverified_site_channel_count} unverified Site Channels created"
      puts "#{new_youtube_channel_count} Youtube Channels created"

      unless args[:commit]
        separator
        puts "Trial Run: Rolling Back"

        raise ActiveRecord::Rollback, "Trial Run: Rolling Back"
      else
        puts "Publishers data has been migrated to owners and channels"
      end
    end
  end
end