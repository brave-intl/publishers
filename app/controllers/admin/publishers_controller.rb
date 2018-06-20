class Admin::PublishersController < AdminController
  before_action :get_publisher

  def index
    @publishers = Publisher
    if params[:q].present?
      @publishers = @publishers.where("email ILIKE :email OR name ILIKE :name",
                      {
                        email: "%#{params[:q]}%",
                        name: "%#{params[:q]}%"
                      }
                    )
    end

    @publishers = @publishers.paginate(page: params[:page])
  end

  private

  def get_publisher
    return unless params[:id].present? || params[:publisher_id].present?
    @publisher = Publisher.find(params[:id] || params[:publisher_id])
  end
end
