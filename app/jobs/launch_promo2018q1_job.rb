# Generates the promo tokens and sends emails
class LaunchPromo2018q1Job < ApplicationJob
  include PromosHelper

  queue_as :default

  def perform
    return unless promo_running?
    publishers = Publisher.all

    publishers.find_each do |publisher|
      PublisherPromoToken2018q1Generator.new(publisher: publisher)      
    end

    publishers.find_each do |publisher|
      PromoMailer.activate_promo_2018q1(publisher).deliver
    end
  end
end
