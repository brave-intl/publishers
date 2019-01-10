namespace :database_updates do
  task :migrate_versions => :environment do
    class LegacyVersion < ApplicationRecord ; end
    class Version < ApplicationRecord ; end

    total = LegacyVersion.count

    Rails.logger.info "[#{Time.now.iso8601}] Starting migration - migrating #{total} items"
    puts "[#{Time.now.iso8601}] Starting migration - migrating #{total} items"

    values = []

    LegacyVersion.in_batches.each_record.with_index do |legacy_version, index|
      printf("\rPercentage: %.2f%", (index/total.to_f * 100))

      item_id = extract_id(legacy_version.object || legacy_version.object_changes)

      # If there is no object associated with this then just move on
      # also skip models that don't exist anymore
      next if item_id.blank?
      next unless is_a_class?(legacy_version.item_type)

      values << ActiveRecord::Base.send(
        :sanitize_sql_array,
        [
          "(:item_type, :item_id, :event, :whodunnit, :object, :object_changes, :created_at)",
          item_type: legacy_version.item_type,
          item_id: item_id,
          event: legacy_version.event,
          whodunnit: legacy_version.whodunnit,
          object: legacy_version.object,
          object_changes: legacy_version.object_changes,
          created_at: legacy_version.created_at
        ]
      )

      # Every 1000 entries insert into database
      if (index % 1000).zero?
        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO versions (item_type, item_id, event, whodunnit, object, object_changes, created_at) VALUES
            #{values.join(", ")}
        SQL
        # Reset array
        values = []
      end
    end


    Rails.logger.info "[#{Time.now.iso8601}] #{total}/#{total} - migration complete ✨"
    puts "[#{Time.now.iso8601}] #{total}/#{total} - migration complete ✨"
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
