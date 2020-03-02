class BrowserUserSignUpService < BaseService
  def initialize(uphold_card_id:)
    @uphold_card_id = uphold_card_id
    @uphold_connection = UpholdConnection.new
  end

  def perform
    # TODO: Add uniqueness index
    @uphold_connection.card_id = @uphold_card_id
    uphold_user = BrowserUser.create(role: Publisher::BROWSER_USER)
    @uphold_connection.update(publisher_id: uphold_user.id)
    Promo::UnattachedRegistrar.new(number: 1, 
                                   campaign: PromoCampaign.find_by(name: PromoCampaign::PEER_TO_PEER),
                                   kind: PromoRegistration::PEER_TO_PEER).perform
    uphold_user
  end
end
