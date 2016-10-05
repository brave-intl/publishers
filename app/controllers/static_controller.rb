# Static pages
class StaticController < ApplicationController
  include PublishersHelper

  before_action :redirect_if_current_publisher, only: :index

  def index
  end

  private

  def redirect_if_current_publisher
    return if !current_publisher
    redirect_to publisher_next_step_path(current_publisher)
  end
end
