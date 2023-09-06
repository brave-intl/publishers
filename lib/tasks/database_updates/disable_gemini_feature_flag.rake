namespace :database_updates do
  desc "Disable Gemini for new users until further notice"
  task disable_new_gemini_connections: :environment do
    # Find all user IDs with gemini accounts
    user_ids_with_gemini_accounts = Publisher.where.associated(:gemini_connection).pluck(:id)
    first_user_with_gemini_account_id = user_ids_with_gemini_accounts[0]
    first_user_with_gemini_account = Publisher.find(first_user_with_gemini_account_id)

    puts "Active user Gemini enabled #{first_user_with_gemini_account.reload.gemini_enabled?}"
    puts "Disabling all gemini feature flags"
    # Disable everyone from connetion a Gemini account
    Publisher
      .update_all(
        "feature_flags = jsonb_set(feature_flags, '{gemini_enabled}', to_json(false::bool)::jsonb)"
      )
    puts "Active user Gemini enabled #{first_user_with_gemini_account.reload.gemini_enabled?}"
    # Re-enable only those who currently have Gemini accounts
    puts "Re-enabling for #{user_ids_with_gemini_accounts.count} accounts"
    Publisher.where(id: user_ids_with_gemini_accounts)
      .update_all(
        "feature_flags = jsonb_set(feature_flags, '{gemini_enabled}', to_json(true::bool)::jsonb)"
      )

    puts "Active user Gemini enabled #{first_user_with_gemini_account.reload.gemini_enabled?}"
    puts "Done!"
  end
end
