
namespace :database_updates do
  task :migrate_uphold_connection => :environment do

    puts "Users with uphold_id #{Publisher.where.not(uphold_id: nil).count}"
    users = Publisher.where(uphold_verified: true).or(Publisher.where.not(uphold_id: nil))

    puts "Migrating #{users.count} user's uphold connection"
    # Let's not record timestamp when we're creating these records
    UpholdConnection.record_timestamps=false

    users.find_each.with_index do |user, index|
      begin
        UpholdConnection.create!(
          publisher: user,
          created_at: user.uphold_updated_at || DateTime.now,
          updated_at: user.uphold_updated_at || DateTime.now,
          uphold_id: user.uphold_id,
          uphold_verified: user.uphold_verified
        )

        print '.' if index % 100 == 0

      rescue ActiveRecord::RecordNotUnique
        print "X"
        Rails.logger.info "[#{Time.now.iso8601}] UpholdConnection already exists for publisher [#{user.id}]"
      end
    end

    puts
    puts "✨ Done"
  end
end
