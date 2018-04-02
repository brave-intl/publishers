namespace :mailchimp do
  desc "Initialize the Publishers List and Groups"
  task :info, [:api_key] => [:environment] do |t, args|
    @api_key = args[:api_key] ? args[:api_key] : Rails.application.secrets[:mailchimp_api_key]

    def gibbon_request
      Gibbon::Request.new(api_key: @api_key,
                          debug: Rails.application.secrets[:mailchimp_api_debug],
                          symbolize_keys: true)
    end

    lists = gibbon_request.lists.retrieve.body[:lists].collect do | list |
      {
        id: list[:id],
        name: list[:name],
        categories: gibbon_request.lists(list[:id]).interest_categories.retrieve.body[:categories].collect do | category |
          {
           id: category[:id],
           title: category[:title]
          }
        end
      }
    end

    puts JSON.pretty_generate(lists)
  end
end