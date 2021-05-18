namespace :database_updates do
  desc 'Backfill Publisher Selected Wallets'
  task :backfill_publisher_selected_wallets => :environment do
    def handle_gemini
      gemini_to_set = Publisher.
        joins(:gemini_connection).
        where('gemini_connections.is_verified = TRUE').
        where('publishers.selected_wallet_provider_id IS NULL').
        pluck(:id, 'gemini_connections.id') # use pluck to avoid loading user_authentication_token

      # For testing in dev
      # publisher_ids = GeminiConnection.first(3).map { |p| p.publisher.id }
      # gemini_to_set = Publisher.where(id: publisher_ids).
      #   joins(:gemini_connection).
      #   pluck(:id, 'gemini_connections.id')

      gemini_new_records = gemini_to_set.map do |publisher_gemini|
        {
          id: publisher_gemini[0], # publisher id
          selected_wallet_provider_id: publisher_gemini[1], # gemini connections id
          selected_wallet_provider_type: 'GeminiConnection',
          updated_at: Time.zone.now
        }
      end
      puts "Updating #{gemini_to_set.count} Gemini records"

      Publisher.upsert_all(gemini_new_records) if gemini_new_records.present?
    end

    def handle_bitflyer
      bitflyer_to_set = Publisher.
        joins(:bitflyer_connection).
        where('publishers.selected_wallet_provider_id IS NULL').
        pluck(:id, 'bitflyer_connections.id') # use pluck to avoid loading user_authentication_token

      # For testing in dev
      # publisher_ids = BitflyerConnection.first(2).map { |p| p.publisher.id }
      # bitflyer_to_set = Publisher.where(id: publisher_ids).
      #   joins(:bitflyer_connection).
      #   pluck(:id, 'bitflyer_connections.id')

      bitflyer_new_records = bitflyer_to_set.map do |publisher_bitflyer|
        {
          id: publisher_bitflyer[0], # publisher id
          selected_wallet_provider_id: publisher_bitflyer[1], # bitflyer connections id
          selected_wallet_provider_type: 'BitflyerConnection',
          updated_at: Time.zone.now
        }
      end
      puts "Updating #{bitflyer_to_set.count} Bitflyer records"

      Publisher.upsert_all(bitflyer_new_records) if bitflyer_new_records.present?
    end

    def handle_uphold
      limit = 25000 # To not overwhelm the system

      query_base = Publisher.
        joins(:uphold_connection).
        where('uphold_connections.uphold_verified = TRUE').
        where('publishers.selected_wallet_provider_id IS NULL')

      # For testing in dev
      # publisher_ids = UpholdConnection.first(3).map { |p| p.publisher.id }
      # query_base = Publisher.where(id: publisher_ids).
      #   joins(:uphold_connection)

      query_base.in_batches(of: limit) do |uphold_batch|
        plucked_batch = uphold_batch.pluck(:id, 'uphold_connections.id')

        uphold_new_records = plucked_batch.map do |publisher_uphold|
          {
            id: publisher_uphold[0], # publisher id
            selected_wallet_provider_id: publisher_uphold[1], # uphold connections id
            selected_wallet_provider_type: 'UpholdConnection',
            updated_at: Time.zone.now
          }
        end
        puts "Updating #{plucked_batch.size} uphold records"
        Publisher.upsert_all(uphold_new_records)
      end
    end

    handle_gemini
    handle_bitflyer
    handle_uphold

    puts 'Done!'
  end
end
