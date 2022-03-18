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
