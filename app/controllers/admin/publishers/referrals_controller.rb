class Admin::Publishers::ReferralsController < Admin::PublishersController
  def show
    @publisher = Publisher.find(params[:id] || params[:publisher_id])
    @navigation_view = Views::Admin::NavigationView.new(publisher).as_json.merge({ navbarSelection: "Referrals" }).to_json
  end
end
