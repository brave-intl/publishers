class AdminController < ApplicationController
  before_action :authenticate_admin
  before_filter :protect

  def authenticate_admin
    # TODO: (Albert Wang). Rename this to current_user
    # Intentional duplicate logic
    current_publisher.admin?
  end

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
