require 'docker/eyeshade_helper'

namespace :docker do
  desc "Adds contribution balance"
  task :add_contribution_balance_to_account, [:channel_identifier, :amount] => [:environment] do |task, args|
    channel_identifier = args.channel_identifier
    amount = args.amount

    eyeshade_postgres_cointainer_id = `docker inspect --format="{{.Id}}" eyeshade-postgres`.gsub("\n",'')
    abort("Balance not added because could not find eyeshade postgres docker container.") if eyeshade_postgres_cointainer_id.blank?

    transaction_id = SecureRandom.uuid()
    sql = Docker::EyeshadeHelper.insert_contribution_transaction_sql(channel_identifier, amount, transaction_id)
    sql += Docker::EyeshadeHelper.refresh_account_balances_sql

    puts "running #{sql}"
    `docker exec -it #{eyeshade_postgres_cointainer_id} psql -U postgres eyeshade -c "#{sql}"`
    puts "Added #{amount} BAT of contributions to account #{channel_identifier} (#{transaction_id}). "
  end

  desc "Adds referral balance"
  task :add_referral_balance_to_account, [:owner_identifier, :amount] => [:environment] do |task, args|
    owner_identifier = args.owner_identifier
    amount = args.amount

    eyeshade_postgres_cointainer_id = `docker inspect --format="{{.Id}}" eyeshade-postgres`.gsub("\n",'')
    abort("Balance not added because could not find eyeshade postgres docker container.") if eyeshade_postgres_cointainer_id.blank?

    transaction_id = SecureRandom.uuid()
    sql = Docker::EyeshadeHelper.insert_referral_transaction_sql(owner_identifier, amount, transaction_id)
    sql += Docker::EyeshadeHelper.refresh_account_balances_sql

    `docker exec -it #{eyeshade_postgres_cointainer_id} psql -U postgres eyeshade -c "#{sql}"`
    puts "Added #{amount} BAT of referrals to account #{owner_identifier} (#{transaction_id}). "
  end
end
