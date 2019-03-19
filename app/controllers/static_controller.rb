# Static pages
class StaticController < ApplicationController
  include PublishersHelper

  before_action :redirect_if_current_publisher, only: :index

  def index
    render file: 'public/index.html'
  end

  private

  def redirect_if_current_publisher
    return if !current_publisher
    redirect_to publisher_next_step_path(current_publisher)
  end

  # Copied from PublishersController
  # Level 1 throttling -- After the first two requests, ask user to
  # submit a captcha. See rack-attack.rb for throttle keys.
  def should_throttle_create?
    Rails.env.production? &&
      request.env["rack.attack.throttle_data"] &&
      request.env["rack.attack.throttle_data"]["registrations/ip"] &&
      request.env["rack.attack.throttle_data"]["registrations/ip"][:count] >= THROTTLE_THRESHOLD_CREATE
  end
end
