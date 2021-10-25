namespace :database_updates do
  task migrate_partners: :environment do
    puts "Running partner migration"

    Partner.find_each do |partner|
      partner.membership.destroy if partner.membership.present?

      publisher = partner.becomes(Publisher)
      publisher.feature_flags[UserFeatureFlags::INVOICE] = true
      publisher.role = Publisher::PUBLISHER
      publisher.save
    end

    puts "✨ Done"
  end
end
