class BrowserUserSignUpService < BaseService
  def initialize
  end

  def perform
    # TODO: Add uniqueness index
    uphold_user = BrowserUser.create(role: Publisher::BROWSER_USER)
    Promo::PeerToPeerRegistration.new(
      publisher: uphold_user,
      campaign: PromoCampaign.find_by(name: PromoCampaign::PEER_TO_PEER),
      kind: PromoRegistration::PEER_TO_PEER
    ).perform
    uphold_user
  end
end
