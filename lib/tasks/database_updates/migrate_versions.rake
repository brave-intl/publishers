namespace :database_updates do
  task :migrate_versions => :environment do
    # create temp class to manipulate the versions
    class LegacyVersion < ApplicationRecord ; end
    class Version < ApplicationRecord ; end

    total = LegacyVersion.count

    Rails.logger.info "[#{Time.now.iso8601}] Starting migration - migrating #{total} items"
    LegacyVersion.in_batches.each_record.with_index do |legacy_version, index|
      printf("\rPercentage: %.2f%", (index/total.to_f * 100))

      # If there is no object associated with this then just move on
      item_id = extract_id(legacy_version.object || legacy_version.object_changes)
      next if item_id.blank?
      # Skip models that don't exist anymore
      next unless is_a_class?(legacy_version.item_type)

      new_version = Version.new.tap do |v|
        v.item_type = legacy_version.item_type
        v.item_id = item_id
        v.event = legacy_version.event
        v.whodunnit = legacy_version.whodunnit
        v.object = legacy_version.object
        v.object_changes = legacy_version.object_changes
        v.created_at = legacy_version.created_at
        v.save!
      end
    end

    Rails.logger.info "[#{Time.now.iso8601}] #{total}/#{total} - migration complete ✨"
  end

  def extract_id(item)
    return if item.nil?

    properties = item.split("\n")
    properties.delete_if { |x| x == "- " }

    # Find the correct property
    index = properties.find_index { |p| p[/^id:/] }
    id = properties[index]
    # Creating is different than update
    id = properties[index + 1] if id == "id:"

    id.sub("id: ", "").sub("- ", "").gsub("'", "").strip
  end

  def is_a_class?(item)
    item.constantize
    true
  rescue NameError
    false
  end
end
