# Returns publishers who have abandoned verification process and do not have another publisher account (win back publishers)
class PublisherUnverifiedCalculator < BaseService
  WIN_BACK_THRESHOLD = 5.days

  def perform
    verified_publishers = Publisher.where(verified: true)

    # Only include publishers who have filled contact information
    unverified_publishers = Publisher.where(verified: false).where.not(brave_publisher_id: [nil]).where("created_at < ?", WIN_BACK_THRESHOLD.ago)

    win_back_publishers = []
    unverified_publishers.find_each do |publisher|
      include_publisher = true

      # Check if a verified publisher exists with same brave_publisher_id, email, or phone number
      unless publisher.brave_publisher_id.blank?
        include_publisher = verified_publishers.exists?(brave_publisher_id: publisher.brave_publisher_id) ? false : include_publisher
      end

      include_publisher = verified_publishers.exists?(email: publisher.email) ? false : include_publisher

      unless publisher.phone_normalized.blank?
        include_publisher = verified_publishers.exists?(phone_normalized: publisher.phone_normalized) ? false : include_publisher
      end

      if include_publisher
        win_back_publishers.push(publisher)
      end
    end

    win_back_publishers
  end
end