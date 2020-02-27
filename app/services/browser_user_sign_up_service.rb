class BrowserUserSignUpService < BaseService
  def initialize(uphold_card_id:, uphold_connection:)
    @uphold_card_id = uphold_card_id
    @uphold_connection = uphold_connection
  end

  def perform
    # TODO: Add uniqueness index
    @uphold_connection.card_id = @uphold_card_id
    @uphold_connection.update(publisher_id: uphold_user.id)
    uphold_user = BrowserUser.new
    uphold_user.save
  end
end
