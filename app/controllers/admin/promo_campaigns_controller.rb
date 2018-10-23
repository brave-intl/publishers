class Admin::PromoCampaignsController < AdminController
  def create
    campaign_name = create_params
    PromoCampaign.create(name: campaign_name)
    redirect_to admin_unattached_promo_registrations_path, notice: "Created campaign '#{campaign_name}'."
  end
  
  private

  def create_params
    params.require(:campaign_name)
  end
end