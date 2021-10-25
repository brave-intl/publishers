namespace :refresh do
  task :gemini_tokens, [:id] => :environment do |t, args|
    gemini_last_ran_id = "gemini_last_ran_id"
    last_ran_id = Rails.cache.fetch(gemini_last_ran_id)
    query = GeminiConnection.where.not(encrypted_refresh_token: nil)
    query = query.where("id > ?", last_ran_id) if last_ran_id.present?
    query = query.order(id: :asc)
    query.find_each do |gemini_connection|
      gemini_connection.refresh_authorization!
      Rails.cache.write(gemini_last_ran_id, gemini_connection.id)
    end
  end
end
