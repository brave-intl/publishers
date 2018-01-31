class Api::OwnersController < Api::BaseController
  include PublishersHelper
  include ActionController::Serialization

  def index
    owners = Publisher.where.not(email: nil).order(:created_at)

    page_num = params[:page] || 1
    page_size = params[:per_page] || Rails.application.secrets[:default_api_page_size] || 100
    paginate json: owners, per_page: page_size, page: page_num
  end
end