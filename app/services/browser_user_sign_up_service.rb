class BrowserUserSignUpService < BaseService
  def initialize
  end

  def perform
    uphold_user = BrowserUser.create(role: Publisher::BROWSER_USER)
    PromoClient.peer_to_peer_registration.create(
      publisher: uphold_user,
      promo_campaign: PromoCampaign.find_by(name: PromoCampaign::PEER_TO_PEER)
    )
    uphold_user
  end
end
