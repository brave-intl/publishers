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

  # File format
  # [
  #   {
  #     "address": "123",
  #     "owner": "publishers#uuid:123",
  #     "walletProvider": "uphold",
  #     "walletProviderId": "123",
  #     "publisher": "youtube#channel:dsf",
  #     "note": "Account not permitted"
  #   },
  #   {
  #     "address": "123",
  #     "owner": "publishers#uuid:123",
  #     "walletProvider": "uphold",
  #     "walletProviderId": "123",
  #     "github#channel:38326564",
  #     "note": "Account not permitted"
  #   },
  #   {
  #     "address": "123",
  #     "owner": "publishers#uuid:abc",
  #     "walletProvider": "uphold",
  #     "walletProviderId": "123",
  #     "publisher": " twitter#channel:1554",
  #     "note": ""
  #   },
  #   {
  #     "address": "123",
  #     "owner": "publishers#uuid:abc",
  #     "walletProvider": "uphold",
  #     "walletProviderId": "123",
  #     "publisher": "twitch#author:polistown",
  #     "note": ""
  #   }
  # ]
  desc "Disable wallet connections of creators who fail payout"
  task :failed_payout_status_update, [:status_file] => :environment do |t, args|
    raise "Need status file" unless args[:status_file]

    if args[:status_file].present?
      status_file = args[:status_file]
    end

    to_update_list = JSON.parse(File.read(status_file))

    PublisherPayoutFeedbackStatusUpdater.build.call(to_update_list: to_update_list)
  end

  # File format
  # [
  #  "pubID",
  #  "pubID2",
  #  "pubID3",
  #  "pubID4",
  # ]
  desc "De-whitelist creators who no longer belong on the list"
  task :dewhitelist, [:publisher_file] => :environment do |t, args|
    raise "Need publisher file" unless args[:publisher_file]

    if args[:publisher_file].present?
      publisher_file = args[:publisher_file]
    end

    to_update_list = JSON.parse(File.read(publisher_file))
    to_update_list.each do |publisher_id|
      p = Publisher.where(id: publisher_id).first
      if p&.whitelisted?
        puts "Unwhitelisting publisher #{p.id} with email #{p.email}"
        p.whitelist_updates.destroy_all
      else
        puts "Couldn't find #{publisher_id}"
      end
    end
  end
end
