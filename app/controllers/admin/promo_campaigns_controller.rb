class Admin::PromoCampaignsController < AdminController
  def create
    campaign_name = create_params
    campaign_name.strip!
    campaign = PromoCampaign.create(name: campaign_name)
    if campaign.errors.any?
      # TODO Deal with other error types beyond :taken
      redirect_to admin_unattached_promo_registrations_path, alert: "Campaign name '#{campaign_name}' is already taken."
    else
      redirect_to admin_unattached_promo_registrations_path, notice: "Created campaign '#{campaign_name}'."
    end
  end
  
  private

  def create_params
    params.require(:campaign_name)
  end
end