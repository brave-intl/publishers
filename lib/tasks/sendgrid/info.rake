require "send_grid/api_helper"

namespace :sendgrid do
  desc "Get the Brave Payements list id"
  task :info do |t, args|

    lists = SendGrid::ApiHelper.get_lists

    lists.each do |list|
      puts "#{list['id']}   #{list['name']}"
    end
  end
end