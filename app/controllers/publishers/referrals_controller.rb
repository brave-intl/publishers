class Publishers::ReferralsController < ApplicationController
  include PromosHelper
  before_action :authenticate_publisher!
  def index
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
      promo_campaign_id: params[:promo_campaign_id]).perform
    Promo::RegistrationsStatsFetcher.new(promo_registrations: current_publisher.promo_registrations).perform
  end

  def move_codes
    Promo::OwnerRegistrar.new(
      number: params[:number].to_i,
      publisher_id: current_publisher.id,
      promo_campaign_id: params[:promo_campaign_id]).perform
    Promo::RegistrationsStatsFetcher.new(promo_registrations: current_publisher.promo_registrations).perform
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
end
