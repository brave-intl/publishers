require "csv"

namespace :database_updates do
  desc "Add Initial Uphold Refresh Tokens"
  task add_initial_uphold_refresh_tokens: :environment do
    # accessToken,refreshToken,accessTokenExpiresAt
    # 34672j45f10cfa970d3278a89d12a78603fc02e6,ae8ae283e8af41f43ec49afra6e96td422hf8e93,2021-07-28T11:53:47.170Z
    def handle_uphold
      access_token_to_refresh_token = {}
      CSV.foreach("initial_uphold_tokens.csv", headers: true) do |row|
        access_token_to_refresh_token[row["accessToken"]] = row["refreshToken"]
      end

      expiration_time = 1.hour.seconds.from_now.to_s

      records_to_update = []
      UpholdConnection.where.not(encrypted_uphold_access_parameters: nil).order(id: :asc).find_each do |uphold_connection|
        access_params = uphold_connection.uphold_access_parameters
        if access_params
          parsed_access_params = JSON.parse(access_params)
          if access_token_to_refresh_token.include?(parsed_access_params["access_token"])
            parsed_access_params["refresh_token"] = access_token_to_refresh_token[parsed_access_params["access_token"]]
            parsed_access_params["expiration_time"] = expiration_time
            uphold_connection.uphold_access_parameters = JSON.dump(parsed_access_params)
            records_to_update << uphold_connection
          end
        end
      end

      UpholdConnection.import(records_to_update,
        on_duplicate_key_update: {
          conflict_target: [:id],
          columns: [:encrypted_uphold_access_parameters, :encrypted_uphold_access_parameters_iv]
        },
        validate: false,
        batch_size: 1000)
    end

    handle_uphold

    puts "Done!"
  end
end
