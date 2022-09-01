# typed: ignore

class Admin::Publishers::ReferralsController < Admin::PublishersController
  def index
    @navigation_view = Views::Admin::NavigationView.new(@publisher).as_json.merge({navbarSelection: "Referrals"}).to_json
  end
end
