class TwoFactorRegistrationsController < ApplicationController
  include PublishersHelper

  before_action :authenticate_publisher!

  def index
    @u2f_registrations = current_publisher.u2f_registrations
  end
end
