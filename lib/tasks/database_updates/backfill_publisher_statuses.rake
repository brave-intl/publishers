namespace :database_updates do
  task :backfill_publisher_statuses => :environment do
    admin = Publisher.find_by(email: Rails.application.secrets[:zendesk_admin_email])
    admin = Publisher.first

    publishers = Publisher.all.
        joins('LEFT OUTER JOIN publisher_status_updates ON publisher_status_updates.publisher_id = publishers.id').
        where('publisher_status_updates.publisher_id is NULL').
        order(created_at: :desc)

    publishers.find_each do |publisher|
      note = publisher.notes.create(note: "Backfilling active status", created_by_id: admin.id)
      publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE, publisher_note: note)
      puts "Created #{publisher.id}"
    end

    puts 'Done!'
  end
end
