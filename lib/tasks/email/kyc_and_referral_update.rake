namespace :email do
  task :kyc_and_referral_update, [:id] => :environment do |t, args|
    publisher = Publisher
    if args[:id].present?
      publisher = publisher.where("id > ?", args[:id])
    end

    puts "Emailing #{publisher.count} users"
    publisher.order(id: :asc).limit(4000).find_each.with_index do |user, index|
      begin
        next if user.email.blank? && user.pending_email.blank?

        Batch::EmailUpdateToUserJob.perform_later(user.id)

        print "." if index % 1000 == 0
      rescue => ex
        puts
        puts "Rescued from exception: #{ex.message}"
        puts "Could not send email to #{user.id} - Restart the job by running the following"
        puts
        puts "    rake email:rate_changes[\"#{user.id}\"]"
        break
      end
      p user.id
    end

    puts
    puts "Done"
  end
end
