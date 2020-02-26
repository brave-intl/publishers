class UpholdController < ApplicationController
  def login
    p "wtf"
    # TODO: Make sure these params are safe
    uphold_card_id = params[:uphold_card_id]
    state = SecureRandom.hex(64).to_s
    Rails.cache.write(state, uphold_card_id, expires_in: 10.minutes)
    p "hmm"
    redirect_to Rails.application.secrets[:uphold_authorization_endpoint].
      gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_login_client_id]).
      gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope]).
      gsub('<STATE>', state)
  end

  def confirm
    p params
    uphold_card_id = Rails.cache.fetch(params[:state])
    uphold_code = params[:code]
    if uphold_card_id.present?

      uphold_connection = UpholdConnection.find_by(card_id: uphold_card_id)
      # TODO: Store credentials and read from Uphold to see all the cards that the user owns and make sure they own the card
      parameters = UpholdRequestAccessParameters.new(uphold_code: uphold_code).perform
      # read cards and make sure there's a match
      uphold_connection = UpholdConnection.new(access_parameters: parameters, id: EMPTY_ID)
      result = Uphold::Models::Card.find(uphold_connection: uphold_connection, id: uphold_card_id)

      # TODO: Perhaps a better check
      if result.present?
        signup_user(uphold_card_id) if uphold_connection.nil?
        publisher = UpholdConnection.find_by(card_id: uphold_card_id).publisher
        sign_in(:publisher, publisher)
      end
    else
      p "not found!"
    end
  end

  private

  def signup_user
    # TODO: If we require email, let's just put them through the normal funnel
  end
end
