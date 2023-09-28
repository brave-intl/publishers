class Api::Nextv1::U2fRegistrationsController < Api::Nextv1::BaseController
  include Logout
  include TwoFactorRegistration

  include PendingActions

  before_action :authenticate_publisher!

  def new
    @u2f_registration = U2fRegistration.new
    publisher = current_publisher

    @webauthn_options = WebAuthn::Credential.options_for_create(
      user: {id: publisher.id, name: publisher.email},
      exclude: publisher.u2f_registrations.map { |c| c.key_handle }.compact
    )

    session[:creation_challenge] = @webauthn_options.challenge

    render(json: @webauthn_options.to_json, status: 200)
  end

  class AddU2F < StepUpAction
    call do |publisher_id, webauthn_response, name, challenge|
      current_publisher = Publisher.find(publisher_id)
      result = TwoFactorAuth::WebauthnRegistrationService.build.call(publisher: current_publisher,
        webauthn_response: webauthn_response,
        name: name,
        challenge: challenge)

      case result
      when BSuccess
        logout_everybody_else!(current_publisher)
        render(json: {}, status: 200)
      when BFailure
        render(json: {errors: ["Webauthn registration failed"]}, status: 400) && return
      else
        raise result
      end
    end
  end

  def create
    AddU2F.new(current_publisher.id,
      params[:webauthn_response],
      params.require(:u2f_registration).permit(:name)[:name],
      session[:creation_challenge]).step_up! self
  end

  class RemoveU2F < StepUpAction
    call do |publisher_id, u2f_id|
      current_publisher = Publisher.find(publisher_id)

      u2f_registration = current_publisher.u2f_registrations.find(u2f_id)
      u2f_registration.destroy
    end
  end

  def destroy
    RemoveU2F.new(current_publisher.id, params[:id]).step_up! self

    render(json: {}, status: 200)
  end
end
