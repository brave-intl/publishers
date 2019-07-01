class Admin::Publishers::ReferralsController < Admin::PublishersController
  def show
    @navigation_view = Views::Admin::NavigationView.new(@publisher).as_json.merge({ navbarSelection: "Referrals" }).to_json
  end
end
