module Partners
    class PromoRegistrationsController < ApplicationController
    include PromosHelper

    def create
        Promo::OwnerRegistrar.new(
        number: params[:number].to_i,
        publisher_id: current_publisher.id,
        description: params[:description], 
        promo_campaign_id: params[:promo_campaign_id]).perform
        Promo::RegistrationsStatsFetcher.new(promo_registrations: current_publisher.promo_registrations).perform
    end
    
    def update
        data = params[:id].split(/,/)
        data.each do |code|
        promo_registration = current_publisher.promo_registrations.find(code)
        promo_registration.update(promo_campaign_id: params[:campaign])
        end
    end
    
    def destroy
        promo_registration = current_publisher.promo_registrations.find(params[:id])
        promo_registration.destroy
    end
    end
end