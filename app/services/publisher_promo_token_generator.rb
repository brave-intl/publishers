# Generates a token for a publisher for 2018q1 promotion
class PublisherPromoTokenGenerator < BaseService
  include PromosHelper

  attr_reader :publisher

  def initialize(publisher:, promo_id: active_promo_id, force: false)
    @publisher = publisher
    @promo_id = promo_id
    @force = force
  end

  def perform
    require "sentry-raven"
    case @promo_id
      when "free-bats-2018q1"
        return perform_2018q1
      else
        raise InvalidPromoIdError.new("#{@promo_id} is an invalid promo id") # Rescued and reported in launch promo rake task
    end
  end

  def perform_2018q1
    already_has_promo_token = publisher.promo_token_2018q1.present?

    if already_has_promo_token && !@force
      Rails.logger.info("Publisher #{@publisher} already has a promo token, use force=true to overwrite.")
      nil
    else
      publisher.promo_token_2018q1 = SecureRandom.hex(32)
      publisher.save!
      publisher.promo_token_2018q1
    end
  end
  class InvalidPromoIdError < RuntimeError; end
end