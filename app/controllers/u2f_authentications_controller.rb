class U2fAuthenticationsController < ApplicationController
  include PublishersHelper

  before_action :require_pending_2fa_current_publisher

  def new
    @app_id = u2f.app_id
    publisher = pending_2fa_current_publisher
    key_handles = publisher.u2f_registrations.map(&:key_handle)

    @sign_requests = u2f.authentication_requests(key_handles)
    @challenge = u2f.challenge

    session[:challenge] = @challenge
  end

  def create
    u2f_response = U2F::SignResponse.load_from_json(params[:u2f_response])
    publisher = pending_2fa_current_publisher

    registration = publisher.u2f_registrations.find_by(key_handle: u2f_response.key_handle)

    begin
      u2f.authenticate!(
        session[:challenge],
        u2f_response,
        Base64.decode64(registration.public_key),
        registration.counter
      )
    rescue U2F::Error => e
      Rails.logger.debug("U2F::Error! #{e}")
      redirect_to new_u2f_authentication_path
      return
    ensure
      session.delete(:challenge)
    end

    registration.update!(counter: u2f_response.counter)
    session.delete(:pending_2fa_current_publisher_id)

    sign_in(:publisher, publisher)
    redirect_to publisher_next_step_path(publisher)
  end

  private

  def pending_2fa_current_publisher
    Publisher.find(session[:pending_2fa_current_publisher_id])
  end

  def require_pending_2fa_current_publisher
    if ! session[:pending_2fa_current_publisher_id]
      redirect_to root_path
    end
  end

end
