class Api::OwnersController < Api::BaseController
  include PublishersHelper
  include ActionController::Serialization

  def index
    owners = Publisher.where.not(email: nil).order(:created_at)

    page_num = params[:page] || 1
    page_size = params[:per_page] || Rails.application.secrets[:default_api_page_size] || 100
    paginate json: owners, per_page: page_size, page: page_num
  end

  def create
    @publisher = Publisher.new(pending_email: params[:email])
    if @publisher.save
      PublisherMailer.verify_email(@publisher).deliver_later
      PublisherMailer.verify_email_internal(@publisher).deliver_later if PublisherMailer.should_send_internal_emails?
      render json: @publisher, status: :created
    else
      p @publisher.errors
      render json: @publisher.errors, status: :unprocessable_entity
    end
  end
end
