include PromosHelper
include ActionView::Helpers::SanitizeHelper
module Partners
    class PromoRegistrationsController < ApplicationController
    def create
        Promo::OwnerRegistrar.new(
        number: sanitize(params[:number]).to_i,
        publisher_id: current_publisher.id,
        description: sanitize(params[:description]), 
        promo_campaign_id: sanitize(params[:promo_campaign_id])).perform
    end
    
    def update
        data = sanitize(params[:id]).split(/,/)
        data.each do |code|
        promo_registration = PromoRegistration.find(code)
        promo_registration.update(promo_campaign_id: sanitize(params[:campaign]))
        end
    end
    
    def destroy
        promo_registration = PromoRegistration.find(sanitize(params[:id]))
        promo_registration.destroy
    end
    end
end