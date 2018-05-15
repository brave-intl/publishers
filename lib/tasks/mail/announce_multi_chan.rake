# frozen_string_literal: true

namespace :mail do
  desc "Announce to publishers that we migrated to multi-channel."
  task announce_multi_chan: [:environment] do
    emails_sent = {}
    Publisher.where.not(email: nil).select(%i[id email]).find_each do |publisher|
      email = publisher.email
      next if emails_sent[email]
      AnnouncementMailer.multi_chan(email).deliver_later(queue: :low)
      emails_sent[email] = true
      STDOUT << "."
    end
    puts "\nDone, enqueued #{emails_sent.keys.size} emails."
  end
end
