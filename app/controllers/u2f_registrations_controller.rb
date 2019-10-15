require "concerns/two_factor_registration"

class U2fRegistrationsController < ApplicationController
  include TwoFactorRegistration

  before_action :authenticate_publisher!

  def new
    @u2f_registration = U2fRegistration.new
    @registration_requests = u2f.registration_requests
    session[:challenges] = @registration_requests.map(&:challenge)
    @app_id = u2f.app_id

    @u2f_registrations = current_publisher.u2f_registrations

    key_handles = @u2f_registrations.map(&:key_handle)
    @sign_requests = u2f.authentication_requests(key_handles)
  end

  def create
    u2f_response = U2F::RegisterResponse.load_from_json(params[:u2f_response])

    registration = begin
      u2f.register!(session[:challenges], u2f_response)
    rescue U2F::Error => e
      Rails.logger.debug("U2F::Error! #{e}")
      redirect_to new_u2f_registration_path
      return
    ensure
      session.delete(:challenges)
    end

    permitted = params.require(:u2f_registration).permit(:name)

    current_publisher.u2f_registrations.create!(
      permitted.merge({
        certificate: registration.certificate,
        key_handle: registration.key_handle,
        public_key: registration.public_key,
        counter: registration.counter,
      })
    )

    handle_redirect_after_2fa_registration
  end

  def destroy
    u2f_registration = current_publisher.u2f_registrations.find(params[:id])
    u2f_registration.destroy

    redirect_to security_publishers_path
  end

end
