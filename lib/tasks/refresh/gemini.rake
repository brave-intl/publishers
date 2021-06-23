namespace :refresh do
  task :gemini_tokens, [:id] => :environment do |t, args|
    GEMINI_LAST_RAN_ID = "gemini_last_ran_id"
    last_ran_id = Rails.cache.fetch(GEMINI_LAST_RAN_ID)
    query = GeminiConnection.where.not(encrypted_refresh_token: nil)
    query = query.where("id > ?", last_ran_id) if last_ran_id.present?
    query = query.order(id: :asc)
    query.find_each do |gemini_connection|
      gemini_connection.refresh_authorization!
      Rails.cache.write(GEMINI_LAST_RAN_ID, gemini_connection.id)
    end
  end
end
