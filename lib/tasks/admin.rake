desc "Create admin user"
task :create_admin_user, [:email] => [:environment] do |task, args|
  email = args.email

  if email
    exists = Publisher.find_by_email(email)

    if exists.nil?
      publisher = Publisher.create!(email: email, role: "admin")
      puts publisher
    else
      exists.update!(role: "admin")
      puts exists
    end
  end
end

task :enable_location_feature, [:email] => [:environment] do |task, args|
  Publisher.update_all(feature_flags: {location_enabled: true})
end
