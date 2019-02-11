module Partners
    class ReferralsController < ApplicationController
    include PromosHelper

    def data
        data = {}
        unassigned_codes = current_publisher.promo_registrations.where(promo_campaign_id: nil)
        campaigns = []
    
        current_publisher.promo_campaigns.each do |promo_campaign|
        promo_registrations = current_publisher.promo_registrations.where(promo_campaign_id: promo_campaign.id)
        campaigns.push(
        {
            "promo_campaign_id": promo_campaign.id,
            "name": promo_campaign.name,
            "created_at": promo_campaign.created_at,
            "promo_registrations": promo_registrations
        }
        )
        end
    
        data[:unassigned_codes] = unassigned_codes
        data[:campaigns] = campaigns
    
        render(status: 200, json: data)
    end
    
    def create_codes
        Promo::OwnerRegistrar.new(
        number: params[:number].to_i,
        publisher_id: current_publisher.id,
        description: params[:description], 
        promo_campaign_id: params[:promo_campaign_id]).perform
        Promo::RegistrationsStatsFetcher.new(promo_registrations: current_publisher.promo_registrations).perform
    end
    
    def move_codes
        data = JSON.parse(params[:codes])
        data.each do |code|
        promo_registration = current_publisher.promo_registrations.find(code)
        promo_registration.update(promo_campaign_id: params[:campaign])
        end
    end
    
    def delete_codes
        promo_registration = current_publisher.promo_registrations.find(params[:id])
        promo_registration.destroy
    end
    
    def create_campaign
        promo_campaign = PromoCampaign.create(
            name: params[:name],
            publisher_id: current_publisher.id
        )
        render(status: 200, json: promo_campaign)
    end

    def delete_campaign
        data = JSON.parse(params[:codes])
        data.each do |code|
            promo_registration = current_publisher.promo_registrations.find(code)
            promo_registration.destroy
        end
        campaign = current_publisher.promo_campaigns.find(params[:campaign])
        campaign.destroy
    end
    end
end