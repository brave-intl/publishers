namespace :app_initializer do
  desc "Prepare Application on Boot Up"
  task setup: :environment do
    # Other setup tasks can be done here, such as Elasticsearch caching

    puts "\n== Preparing database =="
    system("bin/rails db:prepare")
  end
end
