require "#{Rails.root}/app/helpers/promos_helper"
include PromosHelper

namespace :promo do
  # Generates the promo tokens and sends emails
  task :launch_promo => :environment do
    begin
      unless promo_running?
        puts "Promo is not running, check the active_promo_id config var."
      end

      publishers = Publisher.all

      publishers.find_each do |publisher|
        PublisherPromoTokenGenerator.new(publisher: publisher)      
      end

      publishers.find_each do |publisher|
        PromoMailer.activate_promo_2018q1(publisher).deliver
      end

    rescue PublisherPromoTokenGenerator::InvalidPromoIdError => error
      require "raven"
      Raven.capture_exception(e)
      puts "Did not launch promo because of invalid promo id. Check the active_promo_id config var."
    end
  end
end