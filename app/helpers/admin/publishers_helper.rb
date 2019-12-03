module Admin
  module PublishersHelper
    def publisher_status(publisher)
      link_to(
        publisher.last_status_update.present? ? publisher.last_status_update.status : "active",
        admin_publisher_publisher_status_updates_path(publisher),
        class: status_badge_class(publisher.last_status_update.present? ? publisher.last_status_update.status : "active")
      )
    end

    def status_badge_class(status)
      label = case status
      when PublisherStatusUpdate::SUSPENDED, PublisherStatusUpdate::ONLY_USER_FUNDS
        "badge-danger"
        "badge-danger"
      when PublisherStatusUpdate::LOCKED
        "badge-warning"
      when PublisherStatusUpdate::NO_GRANTS, PublisherStatusUpdate::HOLD
        "badge-dark"
      when PublisherStatusUpdate::ACTIVE
        "badge-success"
      else
        "badge-secondary"
      end
      "badge #{label}"
    end
  end
end
