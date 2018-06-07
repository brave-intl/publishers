require "send_grid/api_helper"

namespace :sendgrid do
  desc "Update SendGrid with current contacts from Publishers, creating new contacts if needed"
  task :refresh, [:page_size] => [:environment] do |t, args|

    limit = args[:page_size] ? args[:page_size].to_i : 1000
    page = 0

    total_count = Publisher.email_verified.count

    while page * limit < total_count
      publishers = Publisher.email_verified.order(:email).offset(page * limit).limit(limit)
      page = page + 1

      ids = SendGrid::ApiHelper.upsert_contacts(publishers: publishers)

      SendGrid::ApiHelper.add_contacts_to_list(
          list_id: Rails.application.secrets[:sendgrid_publishers_list_id],
          contact_ids: ids)

      print '.'
      # Basic rate limiting (3 requests in 2s)
      sleep(0.75)
    end

    puts "\nDone. Refreshed #{total_count} publishers to SendGrid."
  end
end