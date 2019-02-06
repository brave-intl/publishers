require "send_grid/api_helper"

namespace :sendgrid do
  desc "Create the Brave Rewards list"
  task :init do |t, args|
    begin
      # Custom Fields
      name_field = SendGrid::ApiHelper.get_custom_field(field_name: "name")
      if name_field
        puts "Name field exists: id:#{name_field['id']}"
      else
        name_field = SendGrid::ApiHelper.create_custom_field(field_name: "name", type: "text")
        puts "Name field created: id:#{name_field['id']}"
      end

      phone_number_field = SendGrid::ApiHelper.get_custom_field(field_name: "phone")
      if phone_number_field
        puts "Phone field exists: id:#{phone_number_field['id']}"
      else
        phone_number_field = SendGrid::ApiHelper.create_custom_field(field_name: "phone", type: "text")
        puts "Phone field created: id:#{phone_number_field['id']}"
      end

      # Publisher's List
      publishers_list = SendGrid::ApiHelper.get_list(list_name: 'Brave Rewards')
      if publishers_list
        puts "Brave Rewards list exists: id:#{publishers_list['id']}"
      else
        publishers_list = SendGrid::ApiHelper.create_list(name: 'Brave Rewards')
        puts "Brave Rewards list created: id:#{publishers_list['id']}"
      end
    rescue => e
      puts e
    end
  end
end
