module Admin
  module PublishersHelper
    def publisher_status(publisher)
      link_to(
        publisher.last_status_update.present? ? publisher.last_status_update.status : "active",
        admin_publisher_publisher_status_updates_path(publisher),
        class: status_badge_class(publisher.last_status_update.status)
      )
    end

    def set_mentions(note)
      # Regex to find any @words
      note.scan(/\@(\w*)/).each do |mention|
        # Some reason the regex likes to put an array inside array
        mention = mention[0]
        publisher = Publisher.where("email LIKE ?", "#{mention}@brave.com").first
        if publisher.present?
          # Assuming the administrator is a brave.com email address :)
          note = note.sub("@#{mention}", link_to(publisher.name, admin_publisher_path(publisher)))
        end
      end

      note
    end
  end
end
