class UpholdController < ApplicationController
  def login
    # TODO: Make sure these params are safe
    uphold_card_id = params[:uphold_card_id]
    state = SecureRandom.hex(64).to_s
    Rails.cache.write(state, uphold_card_id, expires_in: 10.minutes)
    redirect_to Rails.application.secrets[:uphold_authorization_endpoint].
      gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_login_client_id]).
      gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope]).
      gsub('<STATE>', state)
  end

  def confirm
    uphold_card_id = Rails.cache.fetch(params[:state])
    uphold_code = params[:code]
    if uphold_card_id.present?
      parameters = UpholdRequestAccessParameters.new(uphold_code: uphold_code, secret_used: UpholdConnection::USE_BROWSER).perform
      # read cards and make sure there's a match
      uphold_connection = UpholdConnection.new(uphold_access_parameters: parameters)
      uphold_model_card = Uphold::Models::Card.new
      searched_uphold_model_card = uphold_model_card.find(uphold_connection: uphold_connection, id: uphold_card_id)

      if searched_uphold_model_card.present? && searched_uphold_model_card.id == uphold_card_id
        signup_user_if_necessary_or_signin(searched_uphold_model_card)
        redirect_to browser_users_home_path
      else
        flash[:alert] = "Sorry, we weren't able to verify your credentials"
        redirect_to root_path
      end
    else
      flash[:alert] = "You must sign in within 10 minutes."
      redirect_to root_path
    end
  end

  private

  def signup_user_if_necessary_or_signin(uphold_model_card)
    uphold_connection = UpholdConnection.find_by(card_id: uphold_model_card.id)
    if uphold_connection.nil?
      user = BrowserUserSignUpService.new.perform
      uphold_connection.update(publisher_id: user.id)
    else
      user = uphold_connection.publisher
    end
    uphold_connection.sync_from_uphold!
    sign_in(:publisher, user)
    uphold_connection
  end
end
