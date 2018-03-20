class Api::OwnersController < Api::BaseController
  include PublishersHelper
  include ActionController::Serialization

  before_action :ensure_json_content_type,
                only: %i(create)

  def index
    owners = Publisher.where.not(email: nil).order(:created_at)

    page_num = params[:page] || 1
    page_size = params[:per_page] || Rails.application.secrets[:default_api_page_size] || 100
    paginate json: owners, per_page: page_size, page: page_num
  end

  def create
    owner = Publisher.new(owner_params)
    owner.save!
    render(json: owner, status: :ok)
  end

  private

  def owner_params
    owner_params = params[:owner].permit(:email, :name, :phone)
    owner_params[:visible] = ActiveRecord::Type::Boolean.new.deserialize(params[:owner].permit(:show_verification_status)[:show_verification_status])
    owner_params[:created_via_api] = true
    owner_params
  end
end