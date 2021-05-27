namespace :database_updates do
  desc 'Backfill Publisher Selected Wallets'
  task :backfill_publisher_selected_wallets => :environment do
    def handle_gemini
      # Can't use update_all https://github.com/rails/rails/issues/522
      # https://stackoverflow.com/questions/1293330/how-can-i-do-an-update-statement-with-join-in-sql-server
      sql = """
      UPDATE publishers
        SET selected_wallet_provider_id = gc.id,
            selected_wallet_provider_type = 'GeminiConnection',
            updated_at = '#{Time.zone.now}'
      FROM gemini_connections AS gc
      WHERE gc.publisher_id = publishers.id
      AND gc.is_verified = TRUE
      AND publishers.selected_wallet_provider_id IS NULL;
      """

      Publisher.connection.execute(sql)
    end

    def handle_bitflyer
      sql = """
      UPDATE publishers
        SET selected_wallet_provider_id = bc.id,
            selected_wallet_provider_type = 'BitFlyerConnection',
            updated_at = '#{Time.zone.now}'
      FROM bitflyer_connections AS bc
      WHERE bc.publisher_id = publishers.id
      AND publishers.selected_wallet_provider_id IS NULL;
      """

      Publisher.connection.execute(sql)
    end

    def handle_uphold
      ids = Publisher.
        joins(:uphold_connection).
        where('uphold_connections.uphold_verified = TRUE').
        where('publishers.selected_wallet_provider_id IS NULL').pluck(:id)

      puts "Have to update #{ids.size} total Uphold accounts"

      ids.each_slice(500) do |chunk_ids|

        sql = """
        UPDATE publishers
          SET selected_wallet_provider_id = uc.id,
              selected_wallet_provider_type = 'UpholdConnection',
              updated_at = '#{Time.zone.now}'
        FROM uphold_connections AS uc
        WHERE uc.publisher_id = publishers.id
        AND publishers.selected_wallet_provider_id IS NULL
        AND uc.uphold_verified = TRUE
        AND publishers.id IN(#{chunk_ids.map{|id| "'#{id}'"}.join(",")})
        """
        puts "Updating #{chunk_ids.size} uphold records"
        Publisher.connection.execute(sql)
      end
    end

    handle_gemini
    handle_bitflyer
    handle_uphold

    puts 'Done!'
  end
end
