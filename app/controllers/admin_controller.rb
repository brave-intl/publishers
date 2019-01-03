class AdminController < ApplicationController
  before_action :protect
  helper_method :sort_column, :sort_direction
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

  # (Albert Wang): Done by subclass. Google `sortable table columns rails` for more details
  def sortable_columns
    []
  end

  def sort_column
    sortable_columns.include?(params[:column]&.to_sym) ? params[:column].to_sym : :id
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
