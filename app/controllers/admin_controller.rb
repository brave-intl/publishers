class AdminController < ApplicationController
  before_action :protect
  include PublishersHelper

  # Override this value to specify the number of elements to display at a time
  # on index pages. Defaults to 20.
  def records_per_page
    20
  end

  private

  def protect
    authorize! :access, :admin
  end
end
