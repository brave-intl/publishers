namespace :mailchimp do
  desc "Update MailChimp with latest values from Publishers, creating new members if needed"
  task :refresh => :environment do
    publishers = Publisher.email_verified

    publishers.each do |publisher|
      RegisterPublisherWithMailChimpJob.perform_later(publisher_id: publisher.id)
    end

    puts "\nDone. Enqueued #{publishers.count} publishers to update at MailChimp."
  end
end