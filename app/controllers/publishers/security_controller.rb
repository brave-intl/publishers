# typed: ignore

module Publishers
  class SecurityController < ApplicationController
    include PublishersHelper
    include TwoFactorRegistration

    before_action :authenticate_publisher!

    def index
      @u2f_registrations = current_publisher.u2f_registrations
    end

    def prompt
      flag_2fa_registration_during_signup
    end
  end
end
