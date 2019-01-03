module Admin
  module PublishersHelper
    def publisher_status(publisher)
      link_to(
        publisher.last_status_update.present? ? publisher.last_status_update.status : "active",
        admin_publisher_publisher_status_updates_path(publisher)
      )
    end
  end
end
