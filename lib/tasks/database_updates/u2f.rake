namespace :database_updates do
  desc "For adding Webauthn, convert u2f PKs to urlsafe Base64"
  task convert_u2f_public_key_format: :environment do
    U2fRegistration.find_each do |r|
      r.format = :u2f
      r.public_key = Base64.urlsafe_encode64(Base64.decode64(r.public_key))
      r.save!
    end
    puts "Done!"
  end
end
