class BrowserUserSignUpService < BaseService
  def initialize
  end

  def perform
    uphold_user = BrowserUser.create(role: Publisher::BROWSER_USER)
    Promo::PeerToPeerRegistration.new(
      publisher: uphold_user,
      promo_campaign_id: PromoCampaign.find_by(name: PromoCampaign::PEER_TO_PEER).id
    ).perform
    uphold_user
  end
end
