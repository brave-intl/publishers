class UpholdConnectionsController < ApplicationController
  UUID_LENGTH = 36

  def login
    ip_whitelist = Rails.application.secrets[:api_ip_whitelist]
    render(status: 401) and return unless ip_whitelist.nil? || request.ip.in?(ip_whitelist)
    uphold_card_id = params[:uphold_card_id]
    render(status: 400, json: {}) and return unless uphold_card_id&.length == UUID_LENGTH
    state = SecureRandom.hex(64).to_s
    Rails.cache.write(state, uphold_card_id, expires_in: 10.minutes)
    redirect_to Rails.application.secrets[:uphold_authorization_endpoint].
      gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_login_client_id]).
      gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope]).
      gsub('<STATE>', state)
  end

  def confirm
    uphold_card_id = Rails.cache.fetch(params[:state])
    uphold_connection, uphold_card = get_card(
      uphold_card_id: uphold_card_id,
      uphold_code: params[:code]
    )

    return redirect_to(root_path, flash: { alert: I18n.t(".out_of_time_alert") }) if uphold_card.blank?
    return redirect_to(root_path, flash: { alert: I18n.t(".invalid_credentials_alert") }) unless uphold_card.id == uphold_card_id

    signup_user_if_necessary_or_signin(
      uphold_model_card: uphold_card,
      uphold_connection: uphold_connection
    )
    redirect_to browser_users_home_path
  end

  private

  def get_card(uphold_card_id:, uphold_code:)
    return [nil, nil] if uphold_card_id.blank?

    parameters = UpholdRequestAccessParameters.new(uphold_code: uphold_code, secret_used: UpholdConnection::USE_BROWSER).perform
    # read cards and make sure there's a match
    uphold_connection = UpholdConnection.new(uphold_access_parameters: parameters)
    uphold_model_card = Uphold::Models::Card.new
    card = uphold_model_card.find(uphold_connection: uphold_connection, id: uphold_card_id)
    [uphold_connection, card]
  end

  def signup_user_if_necessary_or_signin(uphold_model_card:, uphold_connection:)
    if create_uphold_connection?(uphold_model_card: uphold_model_card)
      user = BrowserUserSignUpService.new.perform
      uphold_connection.update(publisher_id: user.id, card_id: uphold_model_card.id)
    else
      uphold_connection = UpholdConnection.find_by(card_id: uphold_model_card.id)
      user = uphold_connection.publisher
    end
    uphold_connection.sync_from_uphold!
    sign_in(:publisher, user)
    uphold_connection
  end

  def create_uphold_connection?(uphold_model_card:)
    uphold_connection = UpholdConnection.find_by(card_id: uphold_model_card.id)
    uphold_connection.nil?
  end
end
