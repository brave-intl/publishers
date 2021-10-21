namespace :cleanup do
  task :names, [:id] => :environment do |t, args|
    Publisher.where("name like '%:%'")
      .or(Publisher.where("name like '%.%'"))
      .or(Publisher.where("name like '%/%'")).find_each do |pub|
      pub.send(:cleanup_name)
      pub.name = pub.name.first(64)
      pub.save(validate: false)
    end
  end
end
