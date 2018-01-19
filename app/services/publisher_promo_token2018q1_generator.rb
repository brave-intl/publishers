# Generates a token for a publisher for 2018q1 promotion
class PublisherPromoToken2018q1Generator < BaseService
  attr_reader :publisher
  
  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return if Rails.application.secrets[:active_promo_id].blank?
    publisher.promo_token_2018q1 = SecureRandom.hex(32)
    publisher.save!
    publisher.promo_token_2018q1
  end
end