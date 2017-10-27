namespace :publisher_statements do
  task :delete_expired => [ :environment ] do
    PublisherStatement.expired.delete_all
  end
end
