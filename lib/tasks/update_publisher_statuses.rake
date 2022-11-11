# To use
# rake "update:publisher_statuses[judgements.json,active,only@notes.org]"
desc "Update Publisher Statuses"
namespace :update do
  task :publisher_statuses, [:status_file, :status, :admin] => :environment do |t, args|
    raise "Need status file" unless args[:status_file]
    raise "Need status" unless args[:status]
    raise "Need admin" unless args[:admin]

    if args[:status_file].present?
      status_file = args[:status_file]
    end
    status = args[:status]
    to_update_list = JSON.parse(File.read(status_file))
    admin = Publisher.where(email: admin).first!

    puts to_update_list.size
    puts to_update_list.first
    to_update_list.each do |channel_identifier, data|
      judgement_note = data["judgements"]
      channel = Channel.find_by_channel_identifier(channel_identifier)
      if channel
        begin
          publisher = channel.publisher
          next if publisher.last_status_update&.status == status
          PublisherStatusUpdater.new.perform(
            user: publisher,
            admin: admin,
            status: status,
            note: judgement_note
          )
        rescue => e
          puts "Error for channel #{channel_identifier}:: #{e.message}"
          next
        end
      else
        puts "Can't find channel #{channel_identifier}"
      end
    end
  end
end
