namespace :database_updates do
  desc 'Reset Permalocked users'
  task :reset_permalocked_users => :environment do
    publisher_ids = []
    PublisherStatusUpdate.select(:status, :publisher_id).where(status: "locked").group(:publisher_id, :status).having("count(*) > 1").each do |psu|
      publisher_ids.append(psu.publisher_id)
    end

    publisher_ids -= TwoFactorAuthenticationRemoval.pluck(:publisher_id)

    Publisher.includes(:status_updates).where(id: publisher_ids).find_each do |publisher|
      if publisher.locked?
        previous_status = publisher.status_updates.select { |status_update| status_update.status != PublisherStatusUpdate::LOCKED }.first.status
        publisher.status_updates.create(status: previous_status)
      end
    end
  end
end
