namespace :email do
  task :tos_update, [:id ] => :environment do |t, args|

    publisher = Publisher
    if args[:id].present?
      publisher = publisher.where("id >= ?", args[:id])
    end

    puts "Emailing #{publisher.count} users"
    publisher.order(id: :desc).find_each.with_index do |user, index|
      begin
        next if user.email.blank? && user.pending_email.blank?

        PublisherMailer.update_to_tos(user).deliver_now
        print '.' if index % 1000 == 0
      rescue => ex
        puts
        puts "Rescued from exception: #{ex.message}"
        puts "Could not send email to #{user.id} - Restart the job by running the following"
        puts
        puts "    rake email:tos_update[\"#{user.id}\"]"
        break
      end
    end

    puts
    puts "Done"
  end
end
