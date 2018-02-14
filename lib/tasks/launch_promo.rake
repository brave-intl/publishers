require "#{Rails.root}/app/helpers/promos_helper"
namespace :promo do
  # Generates the promo tokens and sends emails
  task :launch_promo => :environment do
    include PromosHelper
    begin
      unless promo_running?
        puts "Promo is not running, check the active_promo_id config var."
      end

      publishers = Publisher.where(promo_token_2018q1: nil).where(promo_enabled_2018q1: false).where.not(email: nil)

      publishers.find_each do |publisher|
        token = PublisherPromoTokenGenerator.new(publisher: publisher).perform
        next unless token
        PromoMailer.activate_promo_2018q1(publisher).deliver_later(queue: :low)
      end

    rescue PublisherPromoTokenGenerator::InvalidPromoIdError => error
      require "raven"
      Raven.capture_exception(error)
      puts "Did not launch promo because of invalid promo id. Check the active_promo_id config var."
    end
  end
end