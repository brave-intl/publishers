namespace :email do
  task :tos_update => :environment do
    puts "Emailing #{Publisher.count} users"

    Publisher.order(:id).find_each.with_index do |user, index|
      begin
        PublisherMailer.update_to_tos(user).deliver_now
        print '.' if index % 1000 == 0
      rescue
        # Let's rescue all exceptions
        print "X"
        Rails.logger.info "[#{Time.now.iso8601}] Could not send terms and conditions for [#{user.id}]"
      end
    end

    puts
    puts "✨ Done"
  end
end
