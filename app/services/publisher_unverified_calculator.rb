# Returns publishers who have abandoned verification process and do not have another publisher account (win back publishers)
class PublisherUnverifiedCalculator < BaseService
  WIN_BACK_THRESHOLD = 5.days
  WIN_BACK_MAX_AGE = 30.days

  def perform
    # Only include publishers who have filled contact information
    unverified_channels = Channel.
      where(verified: false).
      where("created_at < ?", WIN_BACK_THRESHOLD.ago).
      where("created_at > ?", WIN_BACK_MAX_AGE.ago)

    win_back_publishers = []

    unverified_channels.find_each do |channel|
      unless win_back_publishers.include?(channel.publisher)
        win_back_publishers.push channel.publisher
      end
    end

    win_back_publishers
  end
end
