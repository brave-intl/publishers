# typed: ignore

module Docker
  class EyeshadeHelper
    # host is docker-compose container name for eyeshade postgres container defined in `bat-ledgers`
    # All the db connection values are coming directly from bat-ledgers/docker-compose.yml
    # Thus any changes to the source code there will break this script

    HOST = "eyeshade-postgres"
    PASSWORD = "password"
    USER = "eyeshade"

    attr_reader :pg_conn

    class << self
      def build
        new.has_eyeshade_migration?
      end

      def eyeshade_db_connection(host: HOST, password: PASSWORD, user: USER)
        begin
          conn = PG.connect(host: host, password: password, user: user)
        rescue => e
          message = "Failed to establish connection to eyeshade database.  Cannot continue with fixture creation. Reason -#{e.message}"
          raise StandardError.new(message)
        end

        conn
      end

      def insert_contribution_transaction_sql(channel_identifier, amount, transaction_id)
        "insert into transactions (id, transaction_type, description, from_account_type, from_account, to_account_type, to_account, amount, channel) values('#{transaction_id}', 'contribution', 'manual insertion', 'uphold', '00000000-0000-4000-0000-000000000000 ', 'channel', '#{channel_identifier}', '#{amount}', '#{channel_identifier}');"
      end

      def insert_referral_transaction_sql(owner_identifier, amount, transaction_id)
        "insert into transactions (id, transaction_type, description, from_account_type, from_account, to_account_type, to_account, amount, channel) values('#{transaction_id}', 'referral', 'manual insertion', 'uphold', '00000000-0000-4000-0000-000000000000 ', 'owner', '#{owner_identifier}', '#{amount}', '#{owner_identifier}');"
      end

      def refresh_account_balances_sql
        "refresh materialized view account_balances;"
      end
    end

    def initialize
      @pg_conn = Docker::EyeshadeHelper.eyeshade_db_connection
    end

    def pg_tables
      @pg_conn.exec("SELECT * FROM pg_catalog.pg_tables;").select { |i| i["schemaname"] == "public" }
    end

    def has_eyeshade_migration?
      if pg_tables.length == 0
        raise StandardError.new("Eyeshade tables not detected, please ensure you have run the required migrations defined in bat-ledgers before running this task")
      end

      self
    end

    def create_site_channel_balances
      insert_channel(SiteChannelDetails)
    end

    def create_twitter_channel_balances
      insert_channel(TwitterChannelDetails)
    end

    def create_youtube_channel_balances
      insert_channel(YoutubeChannelDetails)
    end

    def create_twitch_channel_balances
      insert_channel(TwitchChannelDetails)
    end

    def create_referral_balances
      raise NotImplementedError
    end

    def create_channel_balances
      create_site_channel_balances
      create_twitter_channel_balances
      create_youtube_channel_balances
      create_twitch_channel_balances
      # create_<type>_balances
      # ...
    end

    private

    def insert_channel(model)
      if model.count == 0
        raise StandardError.new("No publishers channels detected, please ensure fixtures have been loaded for the publisher's application")
      end

      model.select("*").each do |channel_details|
        transaction_id = SecureRandom.uuid
        sql = Docker::EyeshadeHelper.insert_contribution_transaction_sql(channel_details.channel_identifier, Random.rand, transaction_id)
        # TODO: Determine the function of this.  Throws an error locally.  Seems like there may be other required DB migrations
        # to handle materialized views.
        #
        # sql += Docker::EyeshadeHelper.refresh_account_balances_sql
        puts "running #{sql}"
        @pg_conn.exec(sql)
      end
    end
  end
end
